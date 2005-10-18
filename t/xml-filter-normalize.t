#!perl -T
# @(#) $Id$

use strict;
use warnings;

use Test::More 'no_plan';
use XML::Filter::Normalize;

my $TEST_NS = 'http://example.com/ns/';

test_basics();
test_nothing_happens_to_correct_data();

sub test_basics {
    my $norm = XML::Filter::Normalize->new();
    isa_ok( $norm, 'XML::Filter::Normalize' );
    can_ok( $norm, qw( correct_element_data ) );
}

sub test_nothing_happens_to_correct_data {
    my $norm = XML::Filter::Normalize->new();
    my $in = {
        Prefix       => 'foo',
        NamespaceURI => $TEST_NS,
        LocalName    => 'bar',
        Name         => 'foo:bar',
        Attributes   => {},
    };
    my $out = $norm->correct_element_data( $in );
    is_deeply( $out, $in, 'correct_element_data() preserves correct input' );
}

# vim: set ai et sw=4 syntax=perl :
