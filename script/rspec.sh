#!/bin/bash

set -e

cd "${0%/*}/.."

echo "----------------------------------------------"
echo "Running rspec..."

bundle exec rspec
