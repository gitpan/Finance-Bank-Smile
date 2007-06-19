use Test::More;

eval {
  require Test::Distribution;
};
if($@) {
  plan skip_all => 'Test::Distribution not installed';
}
else {
  #use Test::Distribution not=>[ qw/pod podcover/];
  use Test::Distribution;
}
