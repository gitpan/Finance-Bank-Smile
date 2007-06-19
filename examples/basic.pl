#!/usr/bin/perl
use strict;
use warnings;

use Finance::Bank::Smile;
my @accounts = Finance::Bank::Smile->check_balance(
    sortCode      => 'xxxxxx',
    accountNumber => 'xxxxxxxx',
    passNumber    => 'xxxx',
    memorableDate => 'xx/xx/xxxx',
    lastSchool    => 'xxxxxxxxxxxxxxxxxx',
    memorableName => 'xxxxxxxxxxxxxxxxxx',
    birthPlace    => 'xxxxxxxxxxxxxxxxxx',
    firstSchool   => 'xxxxxxxxxxxxxxxxxx',
);

print map "$_->{account} $_->{balance}\n",@accounts;

