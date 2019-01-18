use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use Mojo::File 'path';

my $app = path(__FILE__)->dirname->sibling('lite_app');
my $recent = path(__FILE__)->sibling('recent.txt');
my $t = Test::Mojo->new($app, {sharedauth => 'a:b', recent => $recent});
my $cid;
if ( my ($username, $password, $server) = ($ENV{TEST_ONLINE} =~ /^([^:]+):([^@]+)@(.*?)$/) ) {
  diag "$username : $password @ $server";
  $t->app->config(server => $server);
  $t->app->config(username => $username);
  $t->app->config(password => $password);
  my @ids = %{$t->app->get_ncentral_ids||{}};
  diag 'CID: '.join ' => ', @ids[0,1];
  $cid = $ids[1];
} else {
  $t->app->helper(cache => sub { shift });
  $t->app->helper(get_ncentral_ids => sub { {a => 1} });
  diag 'CID: '.join ' => ', 'a', 1;
  $cid = 1;
}

$t->get_ok("/$cid/2")->status_is(200);
$t->get_ok("//a:b@/$cid/2")->status_is(200);
$t->get_ok('/')->status_is(401);
$t->post_ok('/downloads')->status_is(401);
$t->post_ok('/downloads', form => {name => 'a'})->status_is(401);
$t->get_ok("/downloads?cid=$cid")->status_is(401);
$t->get_ok('//b:c@/')->status_is(401);
$t->get_ok('//a:b@/')->status_is(200);
$t->post_ok('//a:b@/downloads')->status_is(302);
$t->post_ok('//a:b@/downloads', form => {name => 'a'})->status_is(200);
$t->get_ok("//a:b@/downloads?cid=$cid")->status_is(200);

$recent->remove;

done_testing();
