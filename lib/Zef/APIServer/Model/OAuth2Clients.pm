package Zef::APIServer::Model::OAuth2Clients;
use Mojo::Base -base;

has 'pg';

sub all { shift->pg->db->query('select * from oauth2_client')->hashes->to_array }


# This is really just to feed to Mojo::Plugin::OAuth2::Server config
sub all_by_name {
    my $clients = shift->all;
    my %index_by_name;
    foreach my $client (@$clients) {
        $index_by_name{$client->{id}} = {
            client_secret => $client->{secret},
            scopes => {
                'distributions:search' => 1,
            },
        }
    }
    return \%index_by_name;
}


1;