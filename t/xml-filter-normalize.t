#!perl -T
# @(#) $Id$

use strict;
use warnings;

use Test::More 'no_plan';
use XML::Filter::Normalize;
use XML::NamespaceSupport;

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
        desc => 'preserves correct input in no namespace',
        in => {
            Prefix       => '',
            NamespaceURI => '',
            LocalName    => 'bar',
            Name         => 'bar',
            Attributes   => {},
        },
        expected => {
            Prefix       => '',
            NamespaceURI => '',
            LocalName    => 'bar',
            Name         => 'bar',
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
    #----------------------------------------
    {
        desc => 'corrects missing NamespaceURI',
        ns => [ [ foo => $TEST_NS ] ],
        in => {
            Attributes   => {},
            LocalName    => 'bar',
            Name         => 'foo:bar',
            Prefix       => 'foo',
        },
        expected => {
            Attributes   => {},
            LocalName    => 'bar',
            Name         => 'foo:bar',
            NamespaceURI => $TEST_NS,
            Prefix       => 'foo',
        },
    },
    #----------------------------------------
    {
        desc => 'corrects missing Prefix & Name',
        ns => [ [ foo => $TEST_NS ] ],
        in => {
            Attributes   => {},
            LocalName    => 'bar',
            NamespaceURI => $TEST_NS,
        },
        expected => {
            Attributes   => {},
            LocalName    => 'bar',
            Name         => 'foo:bar',
            NamespaceURI => $TEST_NS,
            Prefix       => 'foo',
        },
    },
    #----------------------------------------
    {
        desc => 'corrects missing Prefix & NamespaceURI',
        ns => [ [ foo => $TEST_NS ] ],
        in => {
            Attributes   => {},
            Name         => 'foo:bar',
            LocalName    => 'bar',
        },
        expected => {
            Attributes   => {},
            LocalName    => 'bar',
            Name         => 'foo:bar',
            NamespaceURI => $TEST_NS,
            Prefix       => 'foo',
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

    # Add in any supplied namespaces.
    my $nsup = XML::NamespaceSupport->new();
    if ( $t->{ ns } ) {
        $nsup->push_context();
        $nsup->declare_prefix( @$_ ) foreach @{ $t->{ ns } };
    }

    my $out = $norm->correct_element_data( $nsup, $t->{ in } );
    is_deeply( $out, $t->{ expected }, "correct_element() $t->{ desc }" );
}

# vim: set ai et sw=4 syntax=perl :
