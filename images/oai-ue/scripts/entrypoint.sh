#!/bin/bash

set -eo pipefail # don't set 'u' as we need to explicityly test for undefined vars

CONFIG_DIR="/opt/oai-ue/etc"
TEMPLATE=${CONFIG_DIR}/rru.conf.template

# grep variable names (format: ${VAR}) from template to be rendered
VARS=$(grep -oP '\$\{\K[a-zA-Z0-9_]+' ${TEMPLATE} | sort | uniq | xargs)

# create sed expressions for substituting each occurrence of ${VAR}
# with the value of the environment variable "VAR"
EXPRESSIONS=""
for v in ${VARS}; do
    if [[ "${!v}x" == "x" ]]; then
        echo "Error: Environment variable '${v}' is not set." \
             "Config file '$(basename $TEMPLATE)' requires all of $VARS."
        exit 1
    fi
    EXPRESSIONS="${EXPRESSIONS};s|\\\${${v}}|${!v}|g"
done
EXPRESSIONS="${EXPRESSIONS#';'}"

# render template and write to ue.conf
sed "${EXPRESSIONS}" ${TEMPLATE} > ${CONFIG_DIR}/ue.conf

exec "$@"
