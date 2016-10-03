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

wget_options="--quiet --timeout $timeout --http-user $user --http-password $password -O -"

echo "Get list of pets:"
wget $wget_options ${url}/pets
echo

echo "Get one pet:"
wget $wget_options ${url}/pets/1
echo

# http://search.cpan.org/~ams/Mojolicious-4.26/lib/Mojolicious/Guides/Rendering.pod#Encoding
echo "Get one pet gzip => gunzip:"
wget $wget_options --header "Accept-Encoding: gzip" ${url}/pets/1 | zcat -q
echo

exit 0
