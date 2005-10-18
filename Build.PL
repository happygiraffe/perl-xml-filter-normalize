#!/usr/bin/perl -w
# @(#) $Id$

use strict;
use Module::Build;

Module::Build->new(
    module_name => 'XML::Filter::Normalize',
    license     => 'bsd',
    requires    => {
        perl             => '5.6.1',
        'XML::SAX::Base' => 0,
    },
    recommends         => { 'Test::Pod' => 0, },
    create_makefile_pl => 'passthrough',
    add_to_cleanup     => ['XML-Filter-Normalize-*'],
)->create_build_script;
