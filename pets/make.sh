#!/bin/bash

# Program: make.sh
# Purpose: developer demo of the built-in Mojo and Swagger2 command line utilities
# Env: bash
# Usage: ./make.sh

source set.sh

base_url=$PETS_BASE_URL

mypath=./cgi-bin

# verify README.md at http://tmpvar.com/markdown.html
mojo swagger2 validate api.spec
$mypath/pets.cgi routes
mojo swagger2 pod api.spec | pod2html >html/public/pets.html

# the following get commands need authentication credentials

#$mypath/pets.cgi get -M GET $base_url/pets -v
#$mypath/pets.cgi get -M GET $base_url/pets/1 -v
#$mypath/pets.cgi get -M GET $base_url -v

prove
MOJO_CLIENT_DEBUG=1 prove t/basic.t

rm --preserve-root *.tmp

