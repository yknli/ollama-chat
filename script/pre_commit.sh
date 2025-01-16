#!/bin/bash

echo -e "Running pre-commit hooks...\n"

./script/pre_commit_enabled.sh
./script/rubocop.sh
./script/rspec.sh

# $? stores exit value of the last command
if [ $? -ne 0 ]; then
 echo "Pre-commit checks must pass before pushing!"
 exit 1
fi
