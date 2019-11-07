#!/bin/bash

set -eo pipefail # don't set 'u' as we need to explicityly test for undefined vars

CONFIG_DIR="/opt/oai-enb/etc"
DEFAULT_MODE="RCC_BAND38"
MNC_LENGTH=${MNC_LENGTH:-${#MNC}}

# look up configuration template to use
MODE=${MODE:-${DEFAULT_MODE}}
case "${MODE^^}" in
    RCC_BAND38_IF5) TEMPLATE=${CONFIG_DIR}/rcc.b38.if5.conf.template;;
    RCC_BAND38)     TEMPLATE=${CONFIG_DIR}/rcc.b38.conf.template;;
    RCC_BAND40)     TEMPLATE=${CONFIG_DIR}/rcc.band40.tm1.25PRB.FairScheduler.usrpb210.conf.template;;
    RRU)            TEMPLATE=${CONFIG_DIR}/rru.tdd.band40.conf.template;;
    *)              echo "Unkown mode '${MODE}'."; exit 1;;
esac

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

# render template and write to enb.conf
sed "${EXPRESSIONS}" ${TEMPLATE} > ${CONFIG_DIR}/enb.conf

exec "$@"
