#!/bin/bash

# Program: set.sh
# Purpose: setup envariables for test and sample client programs
# Env: bash
# Usage: source set.sh

export PETS_USER=Perl
export PETS_PASSWORD=Bender

export PETS_ADMIN_USER=Admin
export PETS_ADMIN_PASSWORD=Bender

export PETS_SCHEME="http://"
export PETS_DOMAIN=www.example.com
export PETS_BASE_URL="/api/v1.0"
export PETS_TIMEOUT=10

export CLASSPATH="./json-simple-1.1.1.jar:."
