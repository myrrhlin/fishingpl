package Board;

use 5.36.0;

use Moo;
use strictures 2;
use namespace::clean;

use Types::Standard qw( Str Int Enum ArrayRef Object );

use constant {
  BOARD_TILES => 60,
  BOARD_ROWS => 8,
  THREES => 10,
  TWOS => 20,
};

# the board is an array of integers, representing how many fish
# are on each floe tile.  A floe value of 0 means that floe has sunk.
has tile => (
  is => 'ro',
  isa => ArrayRef,
  default => sub { 
    my @array = (1)x BOARD_TILES;
	for (my $cnt = THREES; $cnt > 0; 1) {
	  my $i = int rand(BOARD_TILES);
      next if $array[$i] > 1;
	  $array[$i] = 3;
	  $cnt--;
	}
	for (my $cnt = TWOS; $cnt > 0; 1) {
	  my $i = int rand(BOARD_TILES);
      next if $array[$i] > 1;
	  $array[$i] = 2;
	  $cnt--;
	}
	return \@array;
  },
);

has player_count => (
  is => 'ro',
  isa => Int,
  default => sub { 2 },
);

has penguin_count => (
  is => 'lazy',
  isa => Int,
);
sub _build_penguin_count {
  my $nplayer = shift->player_count;
  return {
	2 => 4*2,
	3 => 3*3,
	4 => 2*4,
  }->{$nplayer} || die "player count must be 2-4";
}

# record the floe number each penguin is on.
# a value of -1 means the penguin is not on the board.
# penguin number $i belongs to player $i % $player_count
has penguin => (
  is => 'lazy',
  isa => ArrayRef,
  default => sub { shift->_randomized_start() },
    # sub { [ (-1)x (shift->penguin_count) ] },
);

sub _randomized_start ($self) {
  my $todo = $self->penguin_count;
  my @penguins;
  while (@penguins < $todo) {
    my $floe = int rand(BOARD_TILES);
	# cannot start on multifish tile:
	next if $self->tile->[$floe] != 1;
	# cannot be on same tile as another penguin
    next if grep {$_ == $floe} @penguins;
	push @penguins, $floe;
  }
  return \@penguins;
}

# given a tile number (0-59) returns a row number
sub row_of ($tile) {
  return int 2*$tile/15;
}

sub print_id ($self) {
  my $line7 = '  %02u'x7;
  my $line8 = '%02u' . $line7;
  my $form = join '', ($line7 ."\n". $line8 ."\n") x4;
  printf $form, 0..59;
}
sub print ($self) {
  my $line7 = '  %2s'x7;
  my $line8 = '%2s' . $line7;
  my $form = join '', ($line7 ."\n". $line8 ."\n") x4;
  my @val = map { "_$_" } $self->tile->@*;
  my @players = (qw< W R B G Y >)[1 .. $self->player_count];
  foreach my $pc (0 .. $self->penguin_count-1) {
    my $tile = $self->penguin->[$pc];
    next unless $tile >= 0;
	my $color = $players[ $pc % $self->player_count ];
	$val[$tile] =~ s/^_/$color/;
  }
  printf $form, @val;
}

1;

