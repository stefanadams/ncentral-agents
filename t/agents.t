use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use Mojo::File 'path';

my $app = path(__FILE__)->dirname->sibling('lite_app');
my $recent = path(__FILE__)->sibling('recent.txt');
my $t = Test::Mojo->new($app, {sharedauth => 'a:b', recent => $recent});
if ( $ENV{TEST_ONLINE} ) {
  my $to = split /\|/, $ENV{TEST_ONLINE};
  $t->app->config(server => $_[0]);
  $t->app->config(username => $_[1]);
  $t->app->config(password => $_[2]);
} else {
  $t->app->helper(cache => sub { shift });
  $t->app->helper(get_ncentral_ids => sub { {a => 1} });
  $t->get_ok('/1/2')->status_is(200);
  $t->get_ok('//a:b@/1/2')->status_is(200);
}

$t->get_ok('/')->status_is(401);
$t->post_ok('/downloads')->status_is(401);
$t->post_ok('/downloads', form => {name => 'a'})->status_is(401);
$t->get_ok('/downloads?cid=1')->status_is(401);
$t->get_ok('//b:c@/')->status_is(401);
$t->get_ok('//a:b@/')->status_is(200);
$t->post_ok('//a:b@/downloads')->status_is(302);
$t->post_ok('//a:b@/downloads', form => {name => 'a'})->status_is(200);
$t->get_ok('//a:b@/downloads?cid=1')->status_is(200);

$recent->remove;

done_testing();
