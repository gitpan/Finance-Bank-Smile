use Test::More;

eval "use require Test::Distribution";
plan skip_all => 'Test::Distribution not installed' if $@;
import Test::Distribution;
