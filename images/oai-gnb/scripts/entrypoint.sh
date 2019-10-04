#!/bin/bash

set -euo pipefail

sed -i \
    -e "s/\${GNB_ID}/${GNB_ID}/g" \
    -e "s/\${GNB_NAME}/${GNB_NAME}/g" \
    -e "s/\${MCC}/${MCC}/g" \
    -e "s/\${MNC}/${MNC}/g" \
    -e "s/\${MNC_LENGTH}/${#MNC}/g" \
    -e "s/\${MME_IP4}/${MME_IP4}/g" \
    -e "s/\${MME_IP6}/${MME_IP6}/g" \
    -e "s/\${S1_MME_IF}/${S1_MME_IF}/g" \
    -e "s/\${S1_MME_IP}/${S1_MME_IP}/g" \
    -e "s/\${S1_U_IF}/${S1_U_IF}/g" \
    -e "s/\${S1_U_IP}/${S1_U_IP}/g" \
    -e "s/\${SDR_FIRST_IP}/${SDR_FIRST_IP}/g" \
    -e "s/\${SDR_SECOND_IP}/${SDR_SECOND_IP}/g" \
    -e "s/\${SDR_MGMT_IP}/${SDR_MGMT_IP}/g" \
    /opt/oai-gnb/etc/gnb.conf

exec "$@"