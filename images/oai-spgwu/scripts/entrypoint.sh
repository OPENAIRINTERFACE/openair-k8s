#!/bin/bash

set -euo pipefail

sed -i \
    -e "s/\${SGW_S1U_INTERFACE}/${SGW_S1U_INTERFACE}/g" \
    -e "s/\${SGW_SX_INTERFACE}/${SGW_SX_INTERFACE}/g" \
    -e "s/\${PGW_SGI_INTERFACE}/${PGW_SGI_INTERFACE}/g" \
    -e "s/\${NETWORK_UE_IP}/${NETWORK_UE_IP}/g" \
    -e "s/\${PGWC_SX_IP_ADDRESS}/${PGWC_SX_IP_ADDRESS}/g" \
    /opt/oai-spgwu/etc/spgw_u.conf

exec "$@"
