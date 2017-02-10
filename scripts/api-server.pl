#!/usr/bin/env perl

use lib 'lib';
use Mojolicious::Commands;

Mojolicious::Commands->start_app('Zef::APIServer');
