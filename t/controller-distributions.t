#!/usr/bin/env perl

use Test::Mojo;
use Test::More;


my $t = Test::Mojo->new('Zef::APIServer');
$t->ua->inactivity_timeout(30);


# START AUTH TESTING AND SETUP
my %authorize_params = (
    client_id     => 'zef_web_frontend',
    client_secret => 'zef_web_frontend_secret',
    response_type => 'code',
    scope         => 'distributions:search',
    redirect_uri  => 'http://client/cb',
);
$t->get_ok( '/oauth/authorize' => form => \%authorize_params )->status_is(302);
ok( my $auth_code = Mojo::URL->new( $t->tx->res->headers->location )->query->param( 'code' ),'includes code' );
my %token_params = (
    client_id     => 'zef_web_frontend',
    client_secret => 'zef_web_frontend_secret',
    grant_type    => 'authorization_code',
    code          => $auth_code,
    redirect_uri  => 'http://client/cb',
);
$t->post_ok( '/oauth/access_token'=> form => \%token_params )
    ->status_is( 200 )
    ->header_is( 'Cache-Control' => 'no-store' )
    ->header_is( 'Pragma'        => 'no-cache' );
my $access_token = $t->tx->res->json->{access_token};
my %oauth_params = ('Authorization' => "Bearer $access_token",);
# END OF AUTH TESTING AND SETUP


subtest 'Distributions#available' => sub {
    $t->get_ok('/api/available' => \%oauth_params)->status_is(200)
        ->json_has('/data/0/name')
        ->json_has('/data/0/version')
        ->json_has('/data/0/auth')
        ->json_has('/total')
        ->json_is('/success', 1);
};


subtest 'Distributions#dependency_graph' => sub {
    # Name and auth match, version doesn't match
    $t->post_ok('/api/dependency_graph' => \%oauth_params => form => {
        name    => 'zef',
        version => 'xxx',
        auth    => 'github:ugexe',
    })->status_is(200)
        ->json_is('/total', 0)
        ->json_is('/success', 1);

    # Name and version match, auth doesn't match
    $t->post_ok('/api/dependency_graph' => \%oauth_params => form => {
        name    => 'zef',
        version => '*',
        auth    => 'xxx',
    })->status_is(200)
        ->json_is('/total', 0)
        ->json_is('/success', 1);

    # Name, version, and auth all match
    $t->post_ok('/api/dependency_graph' => \%oauth_params => form => {
        name    => 'zef',
        version => '*',
        auth    => 'github:ugexe',
    })->status_is(200)
        ->json_is('/data/0/name', 'zef')
        ->json_is('/data/0/version', '*')
        ->json_is('/data/0/auth', 'github:ugexe')
        ->json_is('/total', 1)
        ->json_is('/success', 1);
};


subtest 'Distributions#candidates' => sub {
    # Name and auth match, version doesn't match
    $t->post_ok('/api/candidates' => \%oauth_params => form => {
        name    => 'zef',
        version => 'xxx',
        auth    => 'github:ugexe',
    })->status_is(200)
        ->json_is('/total', 0)
        ->json_is('/success', 1);

    # Name and version match, auth doesn't match
    $t->post_ok('/api/candidates' => \%oauth_params => form => {
        name    => 'zef',
        version => '*',
        auth    => 'xxx',
    })->status_is(200)
        ->json_is('/total', 0)
        ->json_is('/success', 1);

    # Name, version, and auth all match
    $t->post_ok('/api/candidates' => \%oauth_params => form => {
        name    => 'zef',
        version => '*',
        auth    => 'github:ugexe',
    })->status_is(200)
        ->json_is('/data/0/name', 'zef')
        ->json_is('/data/0/version', '*')
        ->json_is('/data/0/auth', 'github:ugexe')
        ->json_is('/total', 1)
        ->json_is('/success', 1);
};


done_testing;