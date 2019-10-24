#!/bin/bash

set -euo pipefail

sed -i \
    -e "s/\${MME_REALM}/${MME_REALM}/g" \
    -e "s|\${MME_CIDR_S1C}|${MME_CIDR_S1C}|g" \
    -e "s|\${MME_CIDR_S11}|${MME_CIDR_S11}|g" \
    -e "s|\${MME_CIDR_S10}|${MME_CIDR_S10}|g" \
    -e "s/\${MME_GID}/${MME_GID}/g" \
    -e "s/\${MME_CODE}/${MME_CODE}/g" \
    -e "s/\${MCC}/${MCC}/g" \
    -e "s/\${MNC}/${MNC}/g" \
    -e "s/\${NW_IF_S1C}/${NW_IF_S1C}/g" \
    -e "s/\${NW_IF_S11}/${NW_IF_S11}/g" \
    -e "s/\${NW_IF_S10}/${NW_IF_S10}/g" \
    -e "s/\${TAC}/${TAC}/g" \
    -e "s/\${HSS_HOSTNAME}/${HSS_HOSTNAME}/g" \
    -e "s|\${SGW_CIDR_S11}|${SGW_CIDR_S11}|g" \
    /opt/oai-mme/etc/mme.conf
sed -i \
    -e "s/\${MME_SERVICE}/${MME_SERVICE}/g" \
    -e "s/\${MME_REALM}/${MME_REALM}/g" \
    -e "s/\${HSS_SERVICE}/${HSS_SERVICE}/g" \
    -e "s/\${HSS_IP}/${HSS_IP}/g" \
    -e "s/\${HSS_REALM}/${HSS_REALM}/g" \
    /opt/oai-mme/etc/mme_fd.conf

exec "$@"
