# A [TDP.me](http://tdp.me) client, in Perl!

## Why Perl?

TDP is mostly built in Perl, so it seems right that Perl gets a client!

## Simple Usage

In order to use the API, a TDP Plus account is required. This is $5 a month and helps me offset development and hosting costs.

    use Net::TDP;

    my $client = Net::TDP->new( api_key => 'Your API key here' );

    $client->list_goals;

    $client->go_read_the_docs_now;

## Contributing

Please feel free to submit an issue, and feel extra free to submit a pull request!

## Credits

Thanks to @rjbs, a gentleman and a scholar, who pushes me to continue doing good stuff.


