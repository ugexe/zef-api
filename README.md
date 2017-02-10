```
# Install
cpanm -v --installdeps .

# Test
perl -Ilib -Ilocal/lib/perl5 scripts/api-server.pl test -v t/*

# View Routes
perl -Ilib -Ilocal/lib/perl5 scripts/api-server.pl routes

# Start Server
perl -Ilib -Ilocal/lib/perl5 scripts/api-server.pl daemon -l "https://*:5000"

```