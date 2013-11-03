#!env perl

use strict;
use warnings;

use Try::Tiny;
use Data::Printer;

use Net::TDP;

warn $ENV{'TDP_API_KEY'};

my $tdp = Net::TDP->new(
  ( $ENV{'TDP_HOST'} ? ( base_url => $ENV{'TDP_HOST'} ) : () ),
  api_key  => $ENV{'TDP_API_KEY'},
);

p $tdp->list_goals;

p $tdp->create_goal(
  name => 'Created from API',
  description => 'From the API',
  color    => "#336699",
  quantity => 1,
  cooldown => 1,
);
