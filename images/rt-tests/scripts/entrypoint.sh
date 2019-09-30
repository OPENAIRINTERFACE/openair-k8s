#!/bin/bash

set -euo pipefail

# if user passes a command as argument, run it,
# else run set of predefined tests
if [ "$#" -ne 0 ]; then
    exec "$@"
else
    exec $(dirname $0)/rt-tests.sh
fi