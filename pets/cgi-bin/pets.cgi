#!/usr/bin/perl

   my $path;
   BEGIN { $path = '/home/example.com/public_html/pets' }

use lib "$path/lib";

   my $base_url    = '/api/v1.0';

   my $auth_type   = 'Basic';

   my $user        = 'Perl';
   my $pw          = 'Bender';
   my $realm       = "Petstore (Try $user:$pw)";

   my $admin_user  = 'Admin';
   my $admin_pw    = 'Bender';
   my $admin_realm = "Petstore Admin (Try $admin_user:$admin_pw)";

   my $s = Pets->new->start;

package Pets;

use Mojo::Base "Mojolicious";
use Mojo::Util 'secure_compare';
use Pets::Controller::Pet;
use MIME::Base64 qw(encode_base64);
use Data::Dumper;

# feature flags ...
use constant FLAG_ENABLE_PAGE_METADATA_ENVELOPE => 1;
use constant FLAG_ALLOW_GET_QS_OR_FORM_AUTH     => 1;
use constant FLAG_ENABLE_AUTHENTICATION         => 1;
 
sub authenticate_api_request {
   my ($next, $c, $action_spec) = @_;

   # throttle
   return $c->respond_to( any => { json => { message => "Too many requests.", error => 429, }, status => 429 } ) if Pets::Controller::Pet::my_throttle($c);

   # Go to the action if allowed ...

   return $next->($c) if (not FLAG_ENABLE_AUTHENTICATION) or 
                         ($c->req->url->path->to_string =~ m[$base_url(/doc|/?)$]) or # needs cleanup
                         (secure_compare $c->req->headers->authorization, $auth_type . ' ' . encode_base64("$user:$pw", '') or
                         (FLAG_ALLOW_GET_QS_OR_FORM_AUTH and secure_compare $c->param('user') . ':' . $c->param('password'), "$user:$pw")
   );

# Not authenticated
   $c->res->headers->append('WWW-Authenticate' => qq[$auth_type realm="$realm"], );

   return $c->respond_to( any => { json => { errors => [{message => "Invalid authorization key", path => "/"}]}, status => 401 } );

#    $c->render(
#      status => 401,
#      json   => {
#        errors => [{message => 'Not authenticated', path => '/'}]
#      }
#    );
#    return;
}

sub authenticate_api_request_admin {
   my ($next, $c, $action_spec) = @_;

   # Go to the action if allowed ...

   return $next->($c) if ($c->req->headers->authorization eq $auth_type . ' ' . encode_base64("$admin_user:$admin_pw", '') or
                         (FLAG_ALLOW_GET_QS_OR_FORM_AUTH and secure_compare $c->param('user') . ':' . $c->param('password'), "$admin_user:$admin_pw")
   );

# Not authenticated
   $c->res->headers->append('WWW-Authenticate' => qq[$auth_type realm="$admin_realm"], );

   return $c->render_swagger( {errors => [{message => "Invalid admin authorization key", path => "/admin"}]}, status => 401 );
}

sub startup {
   my $app = shift;
 
   $app->mode('production');
   $app->secrets(['My very secret passphrase.']);
   $app->title('Pets API');

   $app->plugin('MethodOverride'); # handle X-HTTP-Method-Override: {PUT, PATCH, DELETE} in request header

 # needs to be findable in ./pets and by ./pets/cgi-bin/pets.cgi
   my $spec = "api.spec";
   $spec = '../' . $spec if ! -r $spec;

   $app->plugin(Swagger2 => {
      url => $app->home->rel_file($spec),
   });

   push @{$app->renderer->paths}, $path . "/templates";

   $app->hook(before_dispatch => sub {
      my $c = shift;

   });

   $app->hook(after_render => sub {
      my ($c, $output, $format) = @_;

      my $status = $c->stash->{status} || 0;
      if (FLAG_ENABLE_PAGE_METADATA_ENVELOPE and
          $status == 200 and
          $c->req->url->path->to_string eq "$base_url/pets") {

         my $offset = $c->stash->{my_offset};
         my $limit  = $c->stash->{my_limit};
         my $total  = $c->stash->{my_total};

         # this style of appending another json block after the main response is not elegant. Similar info is in the Link header, so maybe skip this
         $$output = $$output . qq|{"metadata":{"status":"$status","error":"","total":"$total","limit":"$limit","offset":"$offset"}}|;
      }
      elsif ($status == 200 and $c->req->url->path->to_string =~ m[^$base_url/admin/ping]) {
         # skip the pets envelope
         $$output = qq|{"status":"$status","error":"","message":"pong"}|;
      }

      $c->res->headers->header(Copyright => 'Copyright 2016 example.com. All rights reserved.');
   });

   $app->helper(
      render_swagger => sub {
        my ($c, $err, $data, $status) = @_;
        $data = $err if %$err;

        return $c->respond_to(
           # see http://mojolicious.org/perldoc/Mojolicious/Guides/Rendering (Content negotiation)
           xml => { text => Pets::Controller::Pet::encode_xml($data), status => $status },
           any => { json => { pet => $data }, status => $status },

           # some more content negotiation variations ...
           # any => { text => '', status => 200 },
           # any => { ref $data ? (json => $data) : (data => $data), status => $status },
        );
      }
   );
}

