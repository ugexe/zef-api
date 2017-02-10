package Zef::APIServer::Model::Distribution;
use Mojo::Base -base;

has 'pg';

sub add {
  my ($self, $spec) = @_;
  my $sql = 'insert into distributions (name, version, auth, meta) values (?, ?, ?, ?) returning id';
  return $self->pg->db->query($sql, $spec->{name}, $spec->{version}, $spec->{auth}, $spec->{meta})->hash->{id};
}

sub all { shift->pg->db->query('select * from distributions')->hashes->to_array }

sub candidates {
  my ($self, $spec) = @_;
  # TODO: use Perl6 Version objects to find *actual* matches
  my $sql = q|select * from distributions where name = ? AND version LIKE '%?%' AND auth LIKE '%?%'|;
  return $self->pg->db->query($sql, $spec->{name}, $spec->{version} // '', $spec->{auth} // '')->hashes->to_array;
}

# Like `candidates` but only a single result
sub resolve {
  my ($self, $spec) = @_;
  # TODO: use Perl6 Version objects to find *actual* matches
  my $sql = q|select * from distributions where name = ? AND version LIKE '%?%' AND auth LIKE '%?%' LIMIT 1|;
  return $self->pg->db->query($sql, $spec->{name}, $spec->{version} // '', $spec->{auth} // '')->hash;
}


1;