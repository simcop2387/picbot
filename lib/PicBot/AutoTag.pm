package PicBot::AutoTag;

use strict;
use warnings;

use Data::Dumper;
use HTML::TreeBuilder;

#$lut is a table of regex and subs to call when the regex matches
my $lut = [
	[qr"fukung\.net/", \&fukung],
];

sub checkurl {
	my ($ua, $url, $pid) = @_;
    my @tags;
	
	for my $check (@$lut) {
		my $re = $check->[0];
		my $sub = $check->[1];
		
		if ($url =~ $re) {	
			push @tags, $sub->($ua, $url, $pid);
		}
	}
	
	return @tags;	
}

sub fukung {
	my ($ua, $url, $pid) = @_;
	
	my $response = $ua->get($url);

#	print "Got http response\n";
	if (($response->is_success) && ($response->header("Content-Type") =~ m|text/html|))	{
#		print "Success!\n";
		my $html = $response->decoded_content();
		my $tree = HTML::TreeBuilder->new_from_content($html);
		my @taglinks = $tree->look_down("_tag", "a", "href", qr|/tag/|);
		my @tags = map {$a = $_->as_text(); $a =~ s/^\s*//; $a =~ s/\s*$//; $a} @taglinks;
		
#		print "Got tags: ", join(", ", @tags), "\n";
		return @tags, "fukung";
	}
}

1;