package Zef::APIServer;

use Mojo::Pg;
use Zef::APIServer::Model::Distribution;
use Zef::APIServer::Model::OAuth2Clients;

use Mojo::Base "Mojolicious";
use Mojo::Util qw/ slurp spurt /;
use Mojo::JWT;


sub startup {
    my $self = shift;


    # Config
    $self->plugin('Config' => {file => $self->home->rel_file("./api-server.conf")});


    # Model
    $self->helper(pg => sub { state $pg = Mojo::Pg->new(shift->config('pg')) });
    $self->helper(oauth2_clients => sub { state $oauth_clients = Zef::APIServer::Model::OAuth2Clients->new(pg => shift->pg) });
    $self->helper(distributions  => sub { state $dists = Zef::APIServer::Model::Distribution->new(pg => shift->pg) });


    # Migrate to latest version if necessary
    my $oauth_migrations_path = $self->home->child('migrations', 'oauth2_schema.sql');
    $self->pg->migrations->name('oauth2_server')->from_file($oauth_migrations_path)->migrate;
    my $distributions_migrations_path = $self->home->child('migrations', 'distributions_schema.sql');
    $self->pg->migrations->name('distributions')->from_file($distributions_migrations_path)->migrate;


    # OAuth Provider
    $self->plugin(
        'OAuth2::Server' => {
            jwt_secret => $self->config('jwt_secret'),
            clients    => $self->oauth2_clients->all_by_name,
        }
    );


    # OpenAPI
    $self->plugin(
        'OpenAPI' => {
            url => $self->home->rel_file("./openapi/v0.yml"),
        },
    );


    # Protect routes with OAuth
    $self->routes->under('/api' => sub {
        my ( $c ) = @_;
        return 1 if $c->oauth;
        $c->render( status => 401, text => 'Unauthorized' );
        return undef;
    });
}


1;
