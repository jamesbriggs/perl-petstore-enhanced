#!/usr/bin/perl

# Program: perl_client_sample.pl
# Usage: ./perl_client_sample.pl
# Purpose: perl language sample client program for Perl Petstore Enhanced API Server
# Copyright: James Briggs USA 2016
# Env: Perl5
# Returns: exit status is non-zero on failure

use strict;
use diagnostics;

use MIME::Base64 qw(encode_base64);
use LWP::UserAgent;

   my $url = $ENV{'PETS_SCHEME'} . $ENV{'PETS_DOMAIN'} . $ENV{'PETS_BASE_URL'};

   my $api_key      = $ENV{'PETS_USER'};
   my $api_password = $ENV{'PETS_PASSWORD'};

   my $admin_api_key      = $ENV{'PETS_ADMIN_USER'};
   my $admin_api_password = $ENV{'PETS_ADMIN_PASSWORD'};

# Create a user agent object
   my $ua = LWP::UserAgent->new;
   $ua->agent("PetstorePerlBot/0.1");
   $ua->from('perlbot@example.com');
   $ua->timeout($ENV{'PETS_TIMEOUT'} || 10);

# Add auth token to user agent
   $ua->default_header('Authorization' => 'Basic ' . encode_base64("$admin_api_key:$admin_api_password", ''));

{
# Create a request to do a simple health check
   my $req = HTTP::Request->new(GET => $url . '/admin/ping');

# Pass request to the user agent and get a response back
   my $res = $ua->request($req);

   print "info: request #1 - simple health check\n";

# Check the outcome of the response
   if ($res->is_success) {
      print $res->content, "\n";
   }
   else {
      print $res->status_line, "\n";
      exit 6;
   }
}

# Add auth token to user agent
   $ua->default_header('Authorization' => 'Basic ' . encode_base64("$api_key:$api_password", ''));

{
# Create a request for the first page of pets
   my $req = HTTP::Request->new(GET => $url . '/pets');

# Or add auth token to each request
   $req->header('Authorization' => 'Basic ' . encode_base64("$api_key:$api_password", ''));

# Pass request to the user agent and get a response back
   my $res = $ua->request($req);

   print "info: request #2 - show first page of pets\n";

# Check the outcome of the response
   if ($res->is_success) {
      print $res->content, "\n";
   }
   else {
      print $res->status_line, "\n";
      exit 1;
   }
}

{
# Create a request for a pet
   my $req = HTTP::Request->new(GET => $url . '/pets/1');

# Pass request to the user agent and get a response back
   my $res = $ua->request($req);

   print "info: request #3 - get one pet\n";

# Check the outcome of the response
   if ($res->is_success) {
      print $res->content, "\n";
   }
   else {
      print $res->status_line, "\n";
      exit 2;
   }
}

{
# Create a request to add a pet with a POST override in the headers
   my $req = HTTP::Request->new(POST => $url . '/pets');
   $req->header('X-HTTP-Method-Override' => 'PUT');
   $req->content_type('application/json');
   $req->content('{"name": "zebra"}');

# Pass request to the user agent and get a response back
   my $res = $ua->request($req);

   print "info: request #4 - add a pet using POST override\n";

# Check the outcome of the response
   if ($res->is_success) {
      print $res->content, "\n";
   }
   else {
      print $res->status_line, "\n";
      exit 5;
   }
}

{
# Create a request to add a duplicate pet
   my $req = HTTP::Request->new(PUT => $url . '/pets');
   $req->content_type('application/json');
   $req->content('{"name": "alligator"}');

# Pass request to the user agent and get a response back
   my $res = $ua->request($req);

   print "info: request #5 - try to add a duplicate pet\n";

# Check the outcome of the response
   if ($res->is_success) {
      print $res->content, "\n";
   }
   else {
      print $res->status_line, "\n";
      # exit 4;
   }
}

{
   my $success = 0;
   my $location = '';

# Create a request to add a pet
   my $req = HTTP::Request->new(PUT => $url . '/pets');
   $req->content_type('application/json');
   $req->content('{"name": "zebra"}');

# Pass request to the user agent and get a response back
   my $res = $ua->request($req);

   print "info: request #6 - add a pet\n";

# Check the outcome of the response
   if ($res->is_success) {
      print $res->content, "\n";
      $location = $res->header('Location');
      $success = 1;
   }
   else {
      print $res->status_line, "\n";
      exit 3;
   }

   if ($success and $location ne '') {
# Create a request to delete a pet
# Pass request to the user agent and get a response back
      my $res = $ua->delete($location);

      print "info: request #7 - delete a pet\n";

# Check the outcome of the response
      if ($res->is_success) {
      }
      else {
         print "location=$location\n";
         print $res->status_line, "\n";
         exit 3;
      }
   }
}

   exit 0;

