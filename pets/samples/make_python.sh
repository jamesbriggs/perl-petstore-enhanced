#!/bin/bash

# Program: make_python.sh
# Purpose: run pindent.py and pylint on python sample
# Copyright: James Briggs USA 2016
# Env: bash
# Returns: exit status is non-zero on failure
# Usage: ./make_python.sh
# Note:

log=log_pylint.log
prog=python_client_sample.py

rm -f $log

source ../set.sh

./pindent.py -r -s 4 -e $prog
chmod 755 $prog

pylint $prog > $log

exit $?
