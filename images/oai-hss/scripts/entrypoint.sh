#!/bin/bash

set -euo pipefail

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
    -e "s/\${MYSQL_SERVER}/${MYSQL_SERVER}/g" \
    -e "s/\${MYSQL_DATABASE}/${MYSQL_DATABASE}/g" \
    -e "s/\${MYSQL_USER}/${MYSQL_USER}/g" \
    -e "s/\${MYSQL_PASSWORD}/${MYSQL_PASSWORD}/g" \
    -e "s/\${HSS_OP_KEY}/${HSS_OP_KEY}/g" \
    /opt/oai-hss/etc/hss.conf
sed -i \
    -e "s/\${HSS_SERVICE}/${HSS_SERVICE}/g" \
    -e "s/\${HSS_REALM}/${HSS_REALM}/g" \
    /opt/oai-hss/etc/hss_fd.conf
sed -i \
    -e "s/\${HSS_REALM}/${HSS_REALM}/g" \
    /opt/oai-hss/etc/acl.conf

exec "$@"