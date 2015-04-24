#!/usr/bin/env perl
use strict;
use warnings;

use Data::Dumper;

BEGIN { unshift( @INC, './lib' ) }
BEGIN {
    use Test::Most;
    #no warnings 'experimental::smartmatch';
}

my (@site_list, @exp_pats, @unknowns, $pats);

use_ok('Bio::TIGER::Pattern');

@site_list = qw( AAAA ATTA CGGT GGGG );
@exp_pats = {
        "0,1,2,3" => 2,
	"0,3|1,2" => 1,
	"0|1,2|3" => 1
};
@unknowns = [];

$pats = Bio::TIGER::Pattern->new( site_list => \@site_list, unknowns => \@unknowns )->patterns;
print Dumper $pats;
is_deeply $pats, \@exp_pats, 'correct patterns returned';

@site_list = qw( AAAA-TTT ATTA--GG CGGT--GG );
@exp_pats = {
	"0,1,2,3|5,6,7" => 1,
	"0,3|1,2|6,7" => 1,
	"0|1,2,6,7|3" => 1
};
@unknowns = ['-'];

$pats = Bio::TIGER::Pattern->new( site_list => \@site_list, unknowns => \@unknowns )->patterns;
is_deeply $pats, \@exp_pats, 'correct patterns returned';

done_testing();
