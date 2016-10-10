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

file_headers="headers_curl.txt"

url="${scheme}${domain}${base_url}"

options="-sS --max-redirs 3 --max-time $timeout"
auth_options="--basic -u $user:$password"
admin_auth_options="--basic -u $admin_user:$admin_password"

echo "Get list of pets:"
curl $options $auth_options ${url}/pets -w "\n"
ret=$?
echo -e "ret=$ret\n"

echo "Get one pet:"
curl $options $auth_options ${url}/pets/1 -w "\n"
ret=$?
echo -e "ret=$ret\n"

# http://search.cpan.org/~ams/Mojolicious-4.26/lib/Mojolicious/Guides/Rendering.pod#Encoding
echo "Get one pet gzip => gunzip:"
curl $options $auth_options -H "Accept-Encoding: gzip, deflate" ${url}/pets/1 -w "\n" | zcat -q | cat
ret=$?
echo -e "ret=$ret\n"

echo "Add one pet using HERE document:"
curl $options $auth_options -H 'Content-type: application/json' -w "\n" -X PUT --data-binary @- ${url}/pets <<EOF
{"name": "zebra"}
EOF
ret=$?
echo -e "ret=$ret\n"

echo "Add one pet inline:"
curl $options -D $file_headers $auth_options -H 'Content-type: application/json' -w "\n" -X PUT --data-binary '{"name": "zebra"}' ${url}/pets
ret=$?
echo -e "ret=$ret\n"

location=`awk '/Location/{sub(/\r$/,""); print $2}' < $file_headers`

echo "Delete one pet"
rc=`curl $options -o /dev/null -I -w "%{http_code}" $auth_options -X DELETE $location`
ret=$?
echo "rc=$rc"
echo -e "ret=$ret\n"

echo "Basic health check:"
curl $options $admin_auth_options -w "\n" ${url}/admin/ping
ret=$?
echo -e "ret=$ret\n"

exit 0
