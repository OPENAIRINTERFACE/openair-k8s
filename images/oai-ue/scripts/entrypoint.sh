#!/bin/bash

set -euo pipefail

sed -i \
    -e "s/\${UE_IF}/${UE_IF}/g" \
    -e "s/\${UE_IP}/${UE_IP}/g" \
    -e "s/\${ENB_IP}/${ENB_IP}/g" \
    /opt/oai-ue/etc/ue.conf

exec "$@"