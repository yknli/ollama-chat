#!/bin/bash

set -e

cd "${0%/*}/.."

echo "----------------------------------------------"
echo "Running rubocop..."

bin/rubocop -f github
