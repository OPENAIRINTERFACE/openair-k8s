#!/bin/bash

set -euo pipefail

sed -i \
    -e "s/\${ENB_ID}/${GNB_ID}/g" \
    -e "s/\${ENB_NAME}/${GNB_NAME}/g" \
    -e "s/\${MCC}/${MCC}/g" \
    -e "s/\${MNC}/${MNC}/g" \
    -e "s/\${MNC_LENGTH}/${#MNC}/g" \
    -e "s/\${MME_IP4}/${MME_IP4}/g" \
    -e "s/\${MME_IP6}/${MME_IP6}/g" \
    -e "s/\${S1_MME_IF}/${S1_MME_IF}/g" \
    -e "s/\${S1_MME_IP}/${S1_MME_IP}/g" \
    -e "s/\${S1_U_IF}/${S1_U_IF}/g" \
    -e "s/\${S1_U_IP}/${S1_U_IP}/g" \
    -e "s/\${X2C_IP}/${X2C_IP}/g" \
    -e "s/\${CU_IF}/${CU_IF}/g" \
    -e "s/\${CU_IP}/${CU_IP}/g" \
    -e "s/\${DU_IF}/${DU_IF}/g" \
    -e "s/\${DU_IP}/${DU_IP}/g" \
    /opt/oai-enb/etc/enb.conf

exec "$@"