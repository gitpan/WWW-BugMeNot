use strict;
use Test::Base;
use WWW::BugMeNot;

BEGIN {
    eval q{use Test::Exception};
    plan skip_all => 'Test::Exception required for testing exception' if $@;
}

plan tests => 1;

my $client = WWW::BugMeNot->new;

dies_ok(
    sub {my $accounts = $client->get_account_for(); },
    'get_accounts_for():  args not passed in',
);
