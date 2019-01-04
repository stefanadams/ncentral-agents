use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

use Mojo::File 'path';

my $t = Test::Mojo->new(path(__FILE__)->dirname->sibling('lite_app'), {sharedauth => 'a:b'});

$t->get_ok('/')->status_is(401);
$t->get_ok('//b:c@/')->status_is(401);
$t->get_ok('//a:b@/')->status_is(200);
$t->app->helper(get_ncentral_ids => sub { return {a => 1} });
$t->get_ok('/downloads?cid=a')->status_is(200);
$t->get_ok('/1/2')->status_is(200);

done_testing();