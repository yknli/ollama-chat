#!/bin/bash

GIT_DIR=$(git rev-parse --git-dir)

echo "Installing hooks..."

# this command creates symlink to our pre-commit script
ln -nsf ../../script/pre_commit.sh $GIT_DIR/hooks/pre-commit

echo "Done!"
