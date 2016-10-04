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

url="${scheme}${domain}${base_url}"

curl_options="-sS --max-time $timeout --basic -u $user:$password"

echo "Get list of pets:"
curl $curl_options ${url}/pets -w "\n"
echo

echo "Get one pet:"
curl $curl_options ${url}/pets/1 -w "\n"
echo

# http://search.cpan.org/~ams/Mojolicious-4.26/lib/Mojolicious/Guides/Rendering.pod#Encoding
echo "Get one pet gzip => gunzip:"
curl $curl_options -H "Accept-Encoding: gzip" ${url}/pets/1 -w "\n" | zcat -q | cat
echo

echo "Add one pet using HERE document:"
curl $curl_options -H 'Content-type: application/json' -w "\n" -X PUT --data-binary @- ${url}/pets <<EOF
{"name": "zebra"}
EOF
echo

echo "Add one pet inline:"
curl $curl_options -H 'Content-type: application/json' -w "\n" -X PUT --data-binary '{"name": "zebra"}' ${url}/pets
echo

exit 0
