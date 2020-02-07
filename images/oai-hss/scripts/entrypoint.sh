#!/bin/bash

set -euo pipefail

HSS_DOMAIN=${HSS_FQDN#*.}
DB_NAME=${DB_NAME:-vhss}
ROAMING_ALLOWED=${ROAMING_ALLOWED:-true}

CONFIG_FILES=/opt/oai-hss/etc/*
CONFIG_FILES=$(echo $CONFIG_FILES | sed 's#/opt/oai-hss/etc/oss.json##g')

for c in ${CONFIG_FILES}; do
    # grep variable names (format: ${VAR}) from template to be rendered
    VARS=$(grep -oP '\$\{\K[a-zA-Z0-9_]+' ${c} | sort | uniq | xargs)

    # create sed expressions for substituting each occurrence of ${VAR}
    # with the value of the environment variable "VAR"
    EXPRESSIONS=""
    for v in ${VARS}; do
        if [[ "${!v}x" == "x" ]]; then
            echo "Error: Environment variable '${v}' is not set." \
                "Config file '$(basename $c)' requires all of $VARS."
            exit 1
        fi
        EXPRESSIONS="${EXPRESSIONS};s|\\\${${v}}|${!v}|g"
    done
    EXPRESSIONS="${EXPRESSIONS#';'}"

    # render template and inline replace config file
    sed -i "${EXPRESSIONS}" ${c}
done

exec "$@"
