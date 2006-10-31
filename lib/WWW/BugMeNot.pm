package WWW::BugMeNot;

use strict;
use warnings;
use Carp qw(croak);
use URI;
use URI::Fetch;

our $VERSION = '0.01';

sub new { bless {}, $_[0] }

sub get_accounts_for {
    my $self     = shift;
    my $uri      = shift or croak('URI required');
    my @accounts = ();

    my $accounts_page = URI->new('http://www.bugmenot.com/');
    $accounts_page->path('view/' . URI->new($uri)->host);

    my $response = URI::Fetch->fetch($accounts_page)
        or return @accounts;

    my $content = $response->content;

    for my $match ($content =~ m|<div class="account"[^>]+?>(.+?)</div>|imsg) {
        my %extracted;
        my %stats;

        @extracted{qw(username password comment stats)} =
            ($match =~ m|<tr>\s*<th>.*?</th>\s*<td[^>]*?>\s*(.*?)\s*</td>\s*</tr>|imsg);

        @stats{qw(percentage votes)} =
            (_strip_tags($extracted{stats}) =~ m|\s*(?:(\d+)\s*%).+(?:(\d+)\s*votes)\s*|imsg);
        $extracted{stats} = \%stats;

        push @accounts, \%extracted;
    }

    return @accounts;
}

sub _strip_tags {
    my $string = shift or return;
    $string =~ s|<[^>]+?>||imsg;
    $string;
}

1;

__END__

=head1 NAME

WWW::BugMeNot - Get anonymously shared accounts for online services
from BugMeNot

=head1 SYNOPSIS

  use WWW::BugMeNot;

  my $client = WWW::BugMeNot->new;
  my @accounts = $client->get_accounts_for('http://example.com/');

  for my $account (@accounts) {
      print $account->{ username };
      print $account->{ password };
      print $account->{ comment  };
      print $account->{ stats    }{ percentage };
      print $account->{ stats    }{ votes      };
  }

=head1 DESCRIPTION

BugMeNot is a challenging service which collects and shares accounts
for various online services aiming for freeness on online
activities. It allows us to bypass login to online services, sometimes
it's annoying when we want to only take a glance at a strange service,
using accounts got from there.

This module provides a easy way to get such shared accounts easily
from BugMeNot.

=head1 METHODS

=head2 new

=over 4

  my $client = WWW::BugMeNot->new;

Creates and returnss a new WWW::BugMeNot object.

=back

=head2 get_accounts_for ( I<$uri> )

=over 4

  my @accounts = $client->get_accounts_for($uri);

  for my $account (@accounts) {
      $account->{ username };
      $account->{ password };
      $account->{ comment  };
      $account->{ stats    }{ percentage };
      $account->{ stats    }{ votes      };
  }

I<get_accounts_for()> extracts anonymously shared accounts for the
online service indicated by I<$uri>. If the accounts found, returns
them as a list of hash-refs, or returns an empty list.

The accounts are ordered by the percentage which indicate how certain
they are. In most case, you'll pick up the first in return value.

B<NOTE>: BugMeNot now supports only such accounts per domain. URIs like below
will be wrapped up, and this method looks for and extracts accounts
for example.com.

  http://example.com/foo/
  http://example.com/bar/

=back

=head1 SEE ALSO

=over 4

=item * BugMeNot

L<http://www.bugmenot.com/>

=back

=head1 AUTHOR

Kentaro Kuribayashi E<lt>kentaro@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE (The MIT License)

Copyright (c) 2006, Kentaro Kuribayashi E<lt>kentaro@cpan.orgE<gt>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation files
(the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=cut
