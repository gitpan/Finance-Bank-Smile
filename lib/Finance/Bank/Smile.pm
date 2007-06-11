package Finance::Bank::Smile;

use warnings;
use strict;
use Carp;
use WWW::Mechanize;
use HTML::TableExtract;
use Readonly;
use Switch;
our $VERSION = '0.03';

Readonly my $DEBUG => 0;

sub check_balance {
    my ( $class, %opts ) = @_;
    if ( !exists $opts{sortCode} ) { croak 'Must provide a sort code' }
    if ( !exists $opts{accountNumber} ) {
        croak 'Must provide an account number';
    }
    if ( !exists $opts{passNumber} ) { croak 'Must provide a pass number' }
    if ( !exists $opts{memorableDate} ) {
        croak 'Must provide a memorable date';
    }
    if ( !exists $opts{lastSchool} )    { croak 'Must provide a last school' }
    if ( !exists $opts{memorableName} ) { croak 'Must provide memorable name' }
    if ( !exists $opts{birthPlace} )    { croak 'Must provide birth place' }

    if ( !exists $opts{firstSchool} ) { croak 'Must provide first school' }

    my $start_page = 'http://www.smile.co.uk/';

    # hackery for https proxy support
    my $https_proxy = $ENV{https_proxy};
    if ($https_proxy) { delete $ENV{https_proxy} }

    my $mech = WWW::Mechanize->new( env_proxy => 1 );
    $mech->get($start_page);

    # click on "bank login"
    $mech->follow_link( n => 1 );

    _follow_meta_refresh($mech);
    $mech->submit_form(
        form_number => 1,
        fields      => {
            sortCode      => $opts{sortCode},
            accountNumber => $opts{accountNumber},
            passNumber    => $opts{passNumber},
        }
    );

    # now we have to put in the secret info
    my $content = $mech->content();
    switch ($content) {
        case /memorabledate/ {
            my ( $day, $month, $year ) =
              ( $opts{memorableDate} =~ m!^(\d\d)/(\d\d)/(\d{4})!mx );
            if ($DEBUG) { print "memorable date\n" }
            $mech->submit_form(
                form_number => 1,
                fields      => {
                    memorableDay   => $day,
                    memorableMonth => $month,
                    memorableYear  => $year,
                }
            );
        }
        case /lastSchool/ {
            if ($DEBUG) { print "last school\n" }
            $mech->submit_form(
                form_number => 1,
                fields      => {
                    lastSchool => $opts{lastSchool},
                }
            );
        }
        case /memorableName/ {
            if ($DEBUG) { print "memorable name\n" }
            $mech->submit_form(
                form_number => 1,
                fields      => {
                    memorableName => $opts{memorableName},
                }
            );
        }
        case /birthPlace/ {
            if ($DEBUG) { print "birth place\n" }
            $mech->submit_form(
                form_number => 1,
                fields      => {
                    birthPlace => $opts{birthPlace},
                }
            );
        }
        case /firstSchool/ {
            if ($DEBUG) { print "first school\n" }
            $mech->submit_form(
                form_number => 1,
                fields      => {
                    firstSchool => $opts{firstSchool},
                }
            );
        }
        else {
            croak 'Unknown secret information. Cannot logon.';
        }
    };

    # Click past the Smile noticeboard if it appears
    if ( $mech->content() =~ /smile noticeboard/msx ) {
        $mech->click();
    }

    my $te = HTML::TableExtract->new( depth => 3, count => 1 );
    $te->parse( $mech->content() );

    # 0,0 = account type (current account)
    # 0,1 = amount in account (£111.11+)
    # 0,2 = sort code and account number
    # 0,3 = upgrade to smile more?
    my @accounts;
    foreach my $row ( 0 .. 6 ) {
        if ( _strip_white_space( $te->first_table_found->cell( $row, 1 ) ) =~
            /[0-9]/mx )
        {
            (my $balance, my $positive) = (_strip_white_space( $te->first_table_found->cell( $row, 1 )) =~ /(\d+\.\d+)(.+)/mx);
            if (! $positive =~ /\+/mx) {$balance = -$balance}
            push @accounts,
              {
                account =>
                  _strip_white_space( $te->first_table_found->cell( $row, 0 ) ),
                balance => $balance,
              };
        }
    }
    return @accounts;
}

sub _follow_meta_refresh{
  my $mech = shift;
    if ( $mech->response and my $refresh = $mech->response->header('Refresh') )
    {
        my ( $delay, $uri ) = split /;url=/imx, $refresh;
        $uri ||= $mech->uri;    # No URL; reload current URL.
        sleep $delay;
        $mech->get($uri);
    }
   return;
};

sub _strip_white_space {
    my $arg = shift;
    $arg =~ s/^\s+//mx;
    $arg =~ s/\s+$//mx;
    return $arg;
}

1;
__END__

=head1 NAME

Finance::Bank::Smile - Check your Smile bank accounts from Perl

=head1 VERSION

Version 0.03

=head1 SYNOPSIS

use Finance::Bank::Smile;
  my @accounts = Finance::Bank::Smile->check_balance(
      sortCode      => 'xxxxxx',
      accountNumber => 'xxxxxxxx',
      passNumber    => 'xxxx',
      memorableDate => 'xx/xx/xxxx',
      lastSchool    => 'xxxxxxxxxxxxxxxxxx',
      memorableName => 'xxxxxxxx',
      birthPlace    => 'xxxxxx',
      firstSchool   => 'xxxxxxxxxxxx',
  );

  # print the accounts and balances
  # prints:
  # Current Account £123.45+
  print map "$_->{account} $_->{balance}\n",@accounts;

=head1 DESCRIPTION

This module provides a rudimentary interface to the Smile Online
Banking service at C<https://www.smile.co.uk>. You will need either
C<Crypt::SSLeay> or C<IO::Socket::SSL> installed for HTTPS support to
work. C<WWW::Mechanize> and C<HTML::TableExtract> are required.

=head1 CLASS METHODS

=head2 check_balance
  check_balance(
      sortCode      => 'xxxxxx',
      accountNumber => 'xxxxxxxx',
      passNumber    => 'xxxx',
      memorableDate => 'xx/xx/xxxx',
      lastSchool    => 'xxxxxxxxxxxxxxxxxx',
      memorableName => 'xxxxxxxx',
      birthPlace    => 'xxxxxx',
      firstSchool   => 'xxxxxxxxxxxx',
  );

  Returns an array of hash references. The hashes are keyed by 'account' and 'balance'.

=head1 AUTHOR

Richard Panman, C<< <panman.r@gmail.com> >>

=head1 WARNINGS

This warning is from Simon Cozen's C<Finance::Bank::LloydsTSB>, and seems
just as apt here.

This is code for B<online banking>, and that means that B<your money>, and
that means B<BE CAREFUL>. You are encouraged, nay, expected, to audit
the source of this module yourself to reassure yourself that I am not
doing anything untoward with your banking data. This software is useful
to me, but is provided under B<NO GUARANTEE>, explicit or implied.

=head1 BUGS

Please report any bugs or feature requests to
C<bug-finance-bank-smile at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Finance-Bank-Smile>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Finance::Bank::Smile

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Finance-Bank-Smile>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Finance-Bank-Smile>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Finance-Bank-Smile>

=item * Search CPAN

L<http://search.cpan.org/dist/Finance-Bank-Smile>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2007 Richard Panman, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# End of Finance::Bank::Smile
