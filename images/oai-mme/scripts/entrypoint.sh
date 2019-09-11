#!/bin/bash

set -euo pipefail

sed -i \
    -e "s/\${MME_REALM}/${MME_REALM}/g" \
    -e "s/\${MME_IP}/${MY_POD_IP}/g" \
    -e "s/\${MME_GID}/${MME_GID}/g" \
    -e "s/\${MME_CODE}/${MME_CODE}/g" \
    -e "s/\${MCC}/${MCC}/g" \
    -e "s/\${MNC}/${MNC}/g" \
    -e "s/\${TAC}/${TAC}/g" \
    -e "s/\${HSS_HOSTNAME}/${HSS_HOSTNAME}/g" \
    -e "s/\${SGW_IP}/${SGW_IP}/g" \
    /opt/oai-mme/etc/mme.conf
sed -i \
    -e "s/\${MME_SERVICE}/${MME_SERVICE}/g" \
    -e "s/\${MME_REALM}/${MME_REALM}/g" \
    -e "s/\${HSS_SERVICE}/${HSS_SERVICE}/g" \
    -e "s/\${HSS_REALM}/${HSS_REALM}/g" \
    /opt/oai-mme/etc/mme_fd.conf

exec "$@"