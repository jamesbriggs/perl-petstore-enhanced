#!/bin/bash

# Program: wget_client_sample.sh
# Purpose: bash language sample client program for Perl Petstore Enhanced API Server
# Env: bash
# Copyright: James Briggs USA 2016
# Usage: ./wget_client_sample.sh

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

#options="-S --max-redirect=3 --quiet --timeout $timeout --header='Accept-Charset: UTF-8' --header='Content-Type: application/json' -O -"
options="--max-redirect=3 --quiet --timeout $timeout -O -"
auth_options="--auth-no-challenge --http-user $user --http-password $password"
admin_auth_options="--auth-no-challenge --http-user $admin_user --http-password $admin_password"

echo "Get list of pets:"
wget $options $auth_options ${url}/pets
ret=$?
echo -e "\nret=$ret\n"

echo "Get one pet:"
wget $options $auth_options ${url}/pets/1
ret=$?
echo -e "\nret=$ret\n"

# http://search.cpan.org/~ams/Mojolicious-4.26/lib/Mojolicious/Guides/Rendering.pod#Encoding
echo "Get one pet gzip => gunzip:"
wget $options $auth_options --header "Accept-Encoding: gzip, deflate" ${url}/pets/1 | zcat -q
ret=$PIPESTATUS
echo -e "\nret=$ret\n"

echo "Add one pet:"
# newer versions of wget support --method=PUT --body-data=''
#wget $options $auth_options --method=PUT --body-data='{"name":"zebra"}' ${url}/pets
wget $options $auth_options --header='X-HTTP-Method-Override: PUT' --post-data='{"name":"zebra"}' ${url}/pets
ret=$?
echo -e "\nret=$ret\n"

echo "Basic health check:"
wget $options $admin_auth_options ${url}/admin/ping
ret=$?
echo -e "\nret=$ret\n"

exit 0

