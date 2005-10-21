# @(#) $Id$

package XML::Filter::Normalize;

use warnings;
use strict;

use XML::NamespaceSupport;

our $VERSION = '0.01';

use base qw( XML::SAX::Base );

#---------------------------------------------------------------------
# SAX Handlers
#---------------------------------------------------------------------

sub start_document {
    my $self = shift;
    $self->nsup( XML::NamespaceSupport->new() );
    $self->nsup->push_context();
    return $self->SUPER::start_document( @_ );
}

sub end_document {
    my $self = shift;
    $self->nsup( undef );
    return $self->SUPER::end_document( @_ );
}

sub start_prefix_mapping {
    my $self = shift;
    my ( $data ) = @_;
    $self->nsup->declare_prefix( $data->{ Prefix }, $data->{ NamespaceURI } );
    return $self->SUPER::start_prefix_mapping( $data );
}

sub end_prefix_mapping {
    my $self = shift;
    my ( $data ) = @_;
    $self->nsup->undeclare_prefix( $data->{ Prefix } );
    return $self->SUPER::end_prefix_mapping( $data );
}

sub start_element {
    my $self = shift;
    my ( $data ) = @_;
    $self->nsup->push_context();
    $self->correct_element_data( $self->nsup(), $data );
    return $self->SUPER::start_element( $data );
}

sub end_element {
    my $self = shift;
    my ( $data ) = @_;
    $self->correct_element_data( $self->nsup(), $data );
    $self->nsup->pop_context();
    return $self->SUPER::end_element( $data );
}

#---------------------------------------------------------------------
# Internals
#---------------------------------------------------------------------

sub nsup {
    my $self = shift;
    $self->{ nsup } = $_[0] if @_;
    return $self->{ nsup };
}

sub correct_element_data {
    my $self = shift;
    my ( $nsup, $data ) = @_;

    my ( $uri, $prefix, $lname, $name ) =
        $self->extract_name_tuple( $nsup, $data );

    $data->{ NamespaceURI } = $uri;
    $data->{ Prefix }       = $prefix;
    $data->{ LocalName }    = $lname;
    $data->{ Name }         = $name;

    foreach my $v ( values %{ $data->{ Attributes } } ) {
        my ( $uri, $prefix, $lname, $name ) =
            $self->extract_name_tuple( $nsup, $v );
        $v->{ NamespaceURI } = $uri;
        $v->{ Prefix }       = $prefix;
        $v->{ LocalName }    = $lname;
        $v->{ Name }         = $name;
    }

    # XXX Should fix up namespace declarations too.

    return $data;
}

sub extract_name_tuple {
    my $self = shift;
    my ( $nsup, $data ) = @_;
    my ( $uri, $prefix, $lname, $name ) =
        @$data{ qw( NamespaceURI Prefix LocalName Name ) };

    # Take a missing prefix from the name if it's there and looks like
    # we are using a prefix.
    if ( !$prefix && $name && $name =~ m/:/ ) {
        $prefix = ( split /:/, $name, 2 )[0];
    }

    # If we don't have a localname, try to take it from name.
    if ( !$lname && $name ) {
        if ( $name =~ m/:/ ) {
            $lname = ( split /:/, $name, 2 )[1];
        }
        else {
            $lname = $name;
        }
    }

    # If we don't have an NS URI, try to work it out from the prefix.
    # NB: We can't detect anything in the default namespace if it's
    # missing it's URI here.
    if ( !$uri && $prefix ) {
        $uri = $nsup->get_uri( $prefix );
    }

    # If we still have no prefix, but we do have a namespace URI, look
    # it up.
    if ( !$prefix && $uri ) {
        $prefix = $nsup->get_prefix( $uri );
        $prefix = '' if !defined $prefix;
    }

    # Force name to be what we know it should be.
    $name = $prefix ? $prefix . ':' . $lname : $lname;
    return $uri, $prefix, $lname, $name;
}

1;
__END__

=head1 NAME

XML::Filter::Normalize - Clean up SAX event streams

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

  # Just like any normal SAX filter.

=head1 DESCRIPTION

This class implements a "clean up" filter for SAX events.  It's mostly
intended to be used by authors of SAX serializers (eg:
L<XML::SAX::Writer>, L<XML::Genx::SAXWriter>).  If the input event
stream is incomplete in some fashion, it will attempt to correct it
before passing it on.

=head1 METHODS

The following methods are implemented.  All others are handled directly
by L<XML::SAX::Base>.

=over 4

=item start_document()

=item start_prefix_mapping()

=item start_element()

=item end_element()

=item end_prefix_mapping()

=item end_document()

These are standard SAX event handlers.

=item correct_element_data()

=item extract_name_tuple()

=item nsup()

These are private methods and should not be called directly.

=back

=head1 SEE ALSO

L<XML::Genx::SAXWriter>,
L<XML::SAX::Base>,
L<XML::SAX::Writer>.

The conversation that started this module on the perl-xml mailing list.
L<http://aspn.activestate.com/ASPN/Mail/Message/Perl-XML/2858464>

=head1 AUTHOR

Dominic Mitchell, C<< <cpan (at) happygiraffe.net> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-xml-filter-normalize@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-Filter-Normalize>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2005 Dominic Mitchell, all rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

=over 4

=item 1.

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

=item 2.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

=back

THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.

=cut

# vim: set ai et sw=4 :
