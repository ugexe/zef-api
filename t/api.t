#!/usr/bin/env perl

use Test::Mojo;
use Test::More;


my $t = Test::Mojo->new('Zef::APIServer');


$t->get_ok('/api')->status_is(200)
    ->json_is('/swagger', '2.0')
    ->json_is('/consumes', ['application/json'])
    ->json_is('/produces', ['application/json'])
    ->json_is('/info/version', '0.0.1')
    ->json_is('/securityDefinitions/oauthAccessCode/type', 'oauth2');


done_testing;