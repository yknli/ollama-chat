#!/bin/bash

set -e

cd "${0%/*}/../.."

echo "----------------------------------------------"
echo -e "Running pre-commit builtin enabled checks...\n"

pre-commit run git
