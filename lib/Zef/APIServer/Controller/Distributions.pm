package Zef::APIServer::Controller::Distributions;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw/ decode_json encode_json /;


sub dependency_graph {
    my $c     = shift->openapi->valid_input or return;
    my $input = $c->validation->output;

    #return $c->reply->openapi( 401 => {error => "Unauthorized"} )
    #    unless $c->oauth('distributions:search');

    my @dists;
    my @prereqs = $c->distributions->resolve($input);
    if(scalar @prereqs) {
        my %seen;
        while(my $prereq = unshift @prereqs) {
            my $dist = $c->distributions->resolve($prereq);
            unless( $seen{$dist->name}++ ) {
                push @dists, $dist->meta;
                my @deps = $dist->meta->{"depends"}, $dist->meta->{"test-depends"}, $dist->meta->{"build-depends"};
                push @prereqs, @deps;
            }
        }
    }

    return $c->render(openapi => {
        success => 1,
        total   => (scalar @dists),
        data    => \@dists,
    });
}

sub candidates {
    my $c     = shift->openapi->valid_input or return;
    my $input = $c->validation->output;

    #return $c->reply->openapi( 401 => {error => "Unauthorized"} )
    #    unless $c->oauth('distributions:search');

    my @dists = $c->distributions->candidates($input);

    return $c->render(openapi => {
        success => 1,
        total   => (scalar @dists),
        data    => \@dists,
    });
}

sub available {
    my $c     = shift->openapi->valid_input or return;
    my $input = $c->validation->output;

    #return $c->reply->openapi( 401 => {error => "Unauthorized"} )
    #    unless $c->oauth('distributions:search');

    my @dists = $c->distributions->all->[0];
    my @metas = map { decode_json $_->{meta} } @dists;

    return $c->render(openapi => {
        success => 1,
        total   => (scalar @metas),
        data    => \@metas,
    });
}


1;