#!env perl

use strict;
use warnings;

use Try::Tiny;
use DateTime;

use Data::Printer;

use Net::TDP;

my $tdp = Net::TDP->new(
  ( $ENV{'TDP_HOST'} ? ( base_url => $ENV{'TDP_HOST'} ) : () ),
  api_key  => $ENV{'TDP_API_KEY'},
  # Turn on a whole lot of debugging
  #debug    => 1
);

my $autoclean = 0;
my $id = 0;

# Not testing with a specific goal, create one for us to monkey with.
unless ( $id ) {
  my $categories = $tdp->list_categories->{categories};

  my $status = $tdp->create_goal(
    name        => 'Created from API',
    description => 'From the API',
    color       => "#336699",
    quantity    => 1,
    frequency   => 1,
    category_id => $categories->[0]->{id}
  );

  p $status;
  $id = $status->{id};
  $autoclean = 1;
}

if ( $id ) {
  print "Marking $id as completed!\n";
  $tdp->completed(
    id       => $id,
    # Optional note attached to the record
    note     => "note attached to completion record",
    # The date to mark as done, iso8601 or a simple ymd is acceptable
    date     => DateTime->now->subtract(days => 1)->iso8601,

    # These fields are "in development", but they're still accessible.
    # How many did we do? Keep this as one or you may break stuff :)
    quantity => 1,
    # How much time spent (in minutes)
    duration => 45
  );

  if ( $autoclean and $id ) {
    print "Archiving goal $id\n";
    p $tdp->archive_goal(id => $id);
  }
}

p $tdp->list_goals;

