#!/bin/bash

# Program: make_java.sh
# Purpose: build JavaClientSample.java
# Copyright: James Briggs USA 2016
# Env: bash
# Returns: exit status is non-zero on failure
# Usage: ./make_java.sh
# Note:

source ../set.sh

java="/usr/bin/java -client"
#javac="/usr/bin/javac -g:none -Xlint:all"
javac="/usr/bin/javac -Xlint:all"
opt=""
class=JavaClientSample

rm -f $class.class

$javac $opt $class.java

$java $opt $class

