#!/bin/bash

# Program: curl.sh
# Purpose: bash language sample client program for Perl Petstore Enhanced API Server
# Env: bash
# Usage: ./curl.sh

source ../set.sh

domain=$PETS_DOMAIN
base_url=$PETS_BASE_URL
user=$PETS_USER
password=$PETS_PASSWORD
scheme=$PETS_SCHEME

curl --basic -u $user:$password ${scheme}${domain}${base_url}/pets -w "\n"
curl --basic -u $user:$password ${scheme}${domain}${base_url}/pets/1 -w "\n"

