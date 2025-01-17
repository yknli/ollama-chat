#!/bin/bash

set -e

cd "${0%/*}/../.."

echo $pwd
echo "----------------------------------------------"
echo "Running rubocop..."

bin/rubocop -f github
