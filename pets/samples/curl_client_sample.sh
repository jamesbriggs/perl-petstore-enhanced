#!/bin/bash

# Program: curl_client_sample.sh
# Purpose: bash language sample client program for Perl Petstore Enhanced API Server
# Env: bash
# Copyright: James Briggs USA 2016
# Usage: ./curl_client_sample.sh

set -e

source ../set.sh

scheme=$PETS_SCHEME
domain=$PETS_DOMAIN
base_url=$PETS_BASE_URL
timeout=$PETS_TIMEOUT
user=$PETS_USER
password=$PETS_PASSWORD
admin_user=$PETS_ADMIN_USER
admin_password=$PETS_ADMIN_PASSWORD

curl_options="-sS --max-time $timeout"

echo "Get list of pets:"
curl $curl_options --basic -u $user:$password ${scheme}${domain}${base_url}/pets -w "\n"
echo

echo "Get one pet:"
curl $curl_options --basic -u $user:$password ${scheme}${domain}${base_url}/pets/1 -w "\n"
echo

# http://search.cpan.org/~ams/Mojolicious-4.26/lib/Mojolicious/Guides/Rendering.pod#Encoding
echo "Get one pet gzip => gunzip:"
curl $curl_options -H "Accept-Encoding: gzip" --basic -u $user:$password ${scheme}${domain}${base_url}/pets/1 -w "\n" | zcat -q | cat
echo

exit 0
