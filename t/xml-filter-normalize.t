#!perl -T
# @(#) $Id$

use strict;
use warnings;

use Test::More 'no_plan';
use XML::Filter::Normalize;

my $TEST_NS = 'http://example.com/ns/';

test_basics();

my @test_data = (
    {
        desc => 'preserves correct input',
        in => {
            Prefix       => 'foo',
            NamespaceURI => $TEST_NS,
            LocalName    => 'bar',
            Name         => 'foo:bar',
            Attributes   => {},
        },
        expected => {
            Prefix       => 'foo',
            NamespaceURI => $TEST_NS,
            LocalName    => 'bar',
            Name         => 'foo:bar',
            Attributes   => {},
        },
    },
    #----------------------------------------
    {
        desc => 'corrects missing Name',
        in => {
            Prefix       => 'foo',
            NamespaceURI => $TEST_NS,
            LocalName    => 'bar',
            Attributes   => {},
        },
        expected => {
            Prefix       => 'foo',
            NamespaceURI => $TEST_NS,
            LocalName    => 'bar',
            Name         => 'foo:bar',
            Attributes   => {},
        },
    },
    #----------------------------------------
    {
        desc => 'corrects missing Prefix',
        in => {
            Name         => 'foo:bar',
            NamespaceURI => $TEST_NS,
            LocalName    => 'bar',
            Attributes   => {},
        },
        expected => {
            Prefix       => 'foo',
            NamespaceURI => $TEST_NS,
            LocalName    => 'bar',
            Name         => 'foo:bar',
            Attributes   => {},
        },
    },
    #----------------------------------------
    {
        desc => 'corrects missing LocalName',
        in => {
            Prefix       => 'foo',
            Name         => 'foo:bar',
            NamespaceURI => $TEST_NS,
            Attributes   => {},
        },
        expected => {
            Prefix       => 'foo',
            NamespaceURI => $TEST_NS,
            LocalName    => 'bar',
            Name         => 'foo:bar',
            Attributes   => {},
        },
    },
);
test_correct_element_data( $_ ) foreach @test_data;

sub test_basics {
    my $norm = XML::Filter::Normalize->new();
    isa_ok( $norm, 'XML::Filter::Normalize' );
    can_ok( $norm, qw( correct_element_data ) );
}

sub test_correct_element_data {
    my ( $t ) = @_;
    my $norm = XML::Filter::Normalize->new();
    my $out = $norm->correct_element_data( $t->{ in } );
    is_deeply( $out, $t->{ expected }, "correct_element() $t->{ desc }" );
}

# vim: set ai et sw=4 syntax=perl :
