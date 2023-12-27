#! /usr/bin/env perl

use Test::Simple;
use Test::More;
# use Test::Deep;
use Data::Printer;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Board;

my $b = Board->new;

is $b->player_count, 2, 'default 2 players';
is $b->penguin_count, 8, 'should default 8 penguins';
is scalar($b->penguin->@*), 8, 'actually have 8';
is scalar(grep {$_>=0} $b->penguin->@*), $b->penguin_count, 'all penguins on default board';

$b->print;

my $bd = Board->new(player_count => 3);

done_testing();

