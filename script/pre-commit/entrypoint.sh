#!/bin/bash

echo -e "Running pre-commit hooks...\n"

err=0
# if any one of following scripts returns err then err=1
trap 'err=1' ERR

./script/pre-commit/builtin_enabled.sh
./script/pre-commit/rubocop.sh
./script/pre-commit/rspec.sh

# $? stores exit value of the last command
if [ $err -ne 0 ]; then
 echo "Pre-commit checks must pass before pushing!"
 exit 1
fi
