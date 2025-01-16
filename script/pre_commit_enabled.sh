#!/bin/bash

set -e

cd "${0%/*}/.."

echo "----------------------------------------------"
echo -e "Running pre-commit enabled checks...\n"

pre-commit run git
