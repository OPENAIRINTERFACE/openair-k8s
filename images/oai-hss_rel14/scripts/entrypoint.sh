#!/bin/bash

set -euo pipefail

HSS_DOMAIN=${HSS_FQDN#*.}
DB_NAME=${DB_NAME:-vhss}
ROAMING_ALLOWED=${ROAMING_ALLOWED:-true}

sed -i \
    -e "s/\${DB_FQDN}/${DB_FQDN}/g" \
    /opt/oai-hss/etc/hss_rel14.conf
sed -i \
    -e "s/\${HSS_FQDN}/${HSS_FQDN}/g" \
    -e "s/\${HSS_DOMAIN}/${HSS_DOMAIN}/g" \
    -e "s/\${DB_FQDN}/${DB_FQDN}/g" \
    -e "s/\${DB_NAME}/${DB_NAME}/g" \
    -e "s/\${DB_USER}/${DB_USER}/g" \
    -e "s/\${DB_PASSWORD}/${DB_PASSWORD}/g" \
    -e "s/\${OP_KEY}/${OP_KEY}/g" \
    -e "s/\${ROAMING_ALLOWED}/${ROAMING_ALLOWED}/g" \
    /opt/oai-hss/etc/hss_rel14.json
sed -i \
    -e "s/\${HSS_FQDN}/${HSS_FQDN}/g" \
    -e "s/\${HSS_DOMAIN}/${HSS_DOMAIN}/g" \
    /opt/oai-hss/etc/hss_rel14_fd.conf
sed -i \
    -e "s/\${HSS_DOMAIN}/${HSS_DOMAIN}/g" \
    /opt/oai-hss/etc/acl.conf

exec "$@"