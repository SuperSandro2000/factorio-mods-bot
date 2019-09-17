#!/bin/sh
set -eou pipefail

# if the first arg starts with "-" pass it to crond
if [ "${1#-}" != "$1" ]; then
  set -- crond "$@"
fi

exec "$@"
