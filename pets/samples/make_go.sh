#!/bin/bash

# Program: make_go.sh
# Purpose: build go_client_sample.go
# Copyright: James Briggs USA 2016
# Env: bash
# Returns: exit status is non-zero on failure
# Usage: ./make_go.sh
# Note:

source ../set.sh

app=go_client_sample

rm -f $app

go build $app.go && ./$app
echo $?

