#!/usr/bin/env bash

# Install golang
apt install golang -y

# Build the go package in question
make dep                                     # to fetch dependencies
make tests                                   # to run the test suite
make check                                   # to check for any code style issue
make fix                                     # to automatically fix the code style using goimports
make build                                   # to build an executable for your host OS (not tested under windows) 
