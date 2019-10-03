#!/bin/bash

set -euo pipefail

sed -i \
    -e "s/\${SGW_S11_INTERFACE}/${SGW_S11_INTERFACE}/g" \
    -e "s/\${PGW_SX_INTERFACE}/${PGW_SX_INTERFACE}/g" \
    -e "s/\${UE_IP_ADDRESS_POOL}/${UE_IP_ADDRESS_POOL}/g" \
    -e "s/\${UE_DNS_SERVER}/${UE_DNS_SERVER}/g" \
    /opt/oai-spgwc/etc/spgw_c.conf

exec "$@"
