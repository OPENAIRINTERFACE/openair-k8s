#!/bin/bash

set -euo pipefail

DB_NAME=${DB_NAME:-vhss}

cat << EOF > $HOME/.my.cnf
[client]
password=${MYSQL_PASSWORD}
EOF
if ! mysql -h ${MYSQL_SERVER} -u ${MYSQL_USER} -e "use ${MYSQL_DATABASE};" 2>/dev/null; then
    echo "Creating database ${MYSQL_DATABASE} on ${MYSQL_SERVER} and initializing tables."
    mysql -h ${MYSQL_SERVER} -u ${MYSQL_USER} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
    mysql -h ${MYSQL_SERVER} -u ${MYSQL_USER} "${MYSQL_DATABASE}" < /opt/oai-hss/bin/oai_db.sql
fi

sed -i \
    -e "s/\${DB_SERVER}/${DB_SERVER}/g" \
    /opt/oai-hss/etc/hss_rel14.conf
sed -i \
    -e "s/\${DB_SERVER}/${DB_SERVER}/g" \
    -e "s/\${DB_NAME}/${DB_NAME}/g" \
    -e "s/\${DB_USER}/${DB_USER}/g" \
    -e "s/\${DB_PASSWORD}/${DB_PASSWORD}/g" \
    -e "s/\${OP_KEY}/${OP_KEY}/g" \
    /opt/oai-hss/etc/hss_rel14.json
sed -i \
    -e "s/\${HSS_SERVER}/${HSS_SERVER}/g" \
    -e "s/\${HSS_REALM}/${HSS_REALM}/g" \
    /opt/oai-hss/etc/hss_fd.conf
sed -i \
    -e "s/\${HSS_REALM}/${HSS_REALM}/g" \
    /opt/oai-hss/etc/acl.conf

exec "$@"