#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Finance::Bank::Smile' );
}

diag( "Testing Finance::Bank::Smile $Finance::Bank::Smile::VERSION, Perl $], $^X" );
