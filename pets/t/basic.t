# Program: basic.t
# Purpose: test harness program
# Env: Perl5
# Copyright: James Briggs USA 2016
# Usage: source ../set.sh; prove basic.t
#        cd ..; source set.sh; prove
# Returns: exit status is non-zero on failure

use strict;
use diagnostics;

use Test::More;
use Test::Mojo;

use MIME::Base64 qw(encode_base64);

use FindBin; # don't use this under mod_perl, supposedly unsafe
require "$FindBin::Bin/../cgi-bin/pets.cgi";

use constant MAX_REDIRECTS => 3;

   my $doc_match_string  = 'API';
   my $ping_match_string = 'pong';
   my $base_url = $ENV{'PETS_BASE_URL'};

   my $api_key      = $ENV{'PETS_USER'};
   my $api_password = $ENV{'PETS_PASSWORD'};

   my $api_admin_key      = $ENV{'PETS_ADMIN_USER'};
   my $api_admin_password = $ENV{'PETS_ADMIN_PASSWORD'};

   my @pets = qw/alligator cat/;

   my $t = Test::Mojo->new('Pets');

   $t->ua->max_redirects(MAX_REDIRECTS);

# admin
   my $admin_url = $t->ua->server->url->userinfo("$api_admin_key:$api_admin_password");
   my $admin_credentials = 'Basic ' . encode_base64 "$api_admin_key:$api_admin_password";

   # basic health check
   $t->get_ok("$base_url/admin/ping", { Authorization => $admin_credentials }, )->status_is(200)->content_like(qr/$ping_match_string/i);

# public
   my $url = $t->ua->server->url->userinfo("$api_key:$api_password");
   my $credentials = 'Basic ' . encode_base64 "$api_key:$api_password";

   # GET / piggy-backs on the notfound handler, thus the 404 for success
   $t->get_ok("$base_url/", { Authorization => $credentials }, )->status_is(404)->content_like(qr/$doc_match_string/i);

   # not found should be 404
   $t->get_ok("$base_url/pagenotfound", { Authorization => $credentials }, )->status_is(404)->content_like(qr/$doc_match_string/i);

   $t->get_ok("$base_url/doc", { Authorization => $credentials }, )->status_is(200)->content_like(qr/$doc_match_string/i);

   $t->get_ok("$base_url/pets", { Authorization => $credentials }, )->status_is(200)->content_like(qr/alligator/);
   $t->get_ok("$base_url/pets?format=json", { Authorization => $credentials }, )->status_is(200)->content_like(qr/alligator/);
   $t->get_ok("$base_url/pets?format=xml", { Authorization => $credentials }, )->status_is(200)->content_like(qr/alligator/);

   for my $n (1 .. scalar @pets) {
      my $pet = $pets[$n-1];

      $t->get_ok("$base_url/pets/$n", { Authorization => $credentials }, )->status_is(200)->content_like(qr/$pet/);
      $t->get_ok("$base_url/pets/$n?format=json", { Authorization => $credentials }, )->status_is(200)->content_like(qr/$pet/);
      $t->get_ok("$base_url/pets/$n?format=xml", { Authorization => $credentials }, )->status_is(200)->content_like(qr/$pet/);
   }

   $url = $url->path("$base_url/pets");
   my $r = $t->put_ok($url => {Accept => "*/*"} => json => { name => "zebra" })->status_is(201);

   my $location = $r->tx->res->headers->location;

   # $t->delete_ok($location)->status_is(204)->content_like(qr//);
   $t->delete_ok($location);

exit;

   $url = $url->path("$base_url/pets");
   $t->put_ok($url => {Accept => "*/*"} => json => { name => "alligator" })->status_is(409);

   # invalid numeric input should 400
   $url = $url->path("$base_url/pets");
   $t->put_ok($url => {Accept => "*/*"} => json => { name => 1 })->status_is(400);

   done_testing();

