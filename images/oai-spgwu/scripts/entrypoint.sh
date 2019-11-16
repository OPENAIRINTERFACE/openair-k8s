#!/bin/bash

set -euo pipefail

CONFIG_DIR="/opt/oai-spgwu/etc"

for c in ${CONFIG_DIR}/*.conf; do
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

# Test for routing scripts 
for v in PGW_SGI_INTERFACE PGWU_SGI_GW NETWORK_UE_IP; do
    if [[ "${!v}x" == "x" ]]; then
        echo "Error: Environment variable '${v}' is not set." \
                "required for routing scripts"
        exit 1
    fi
done

# This will be done by the spgwu internally soon, but for the time being:
echo '200 lte' | tee --append /etc/iproute2/rt_tables
# Default gateway 
ip route add default via $PGWU_SGI_GW dev $PGW_SGI_INTERFACE table 200
# you will have to repeat the following line for each PDN network set in your SPGW-U config file
ip rule add from $NETWORK_UE_IP table 200

# Actually required since SGi may be not the interface on which is set the default route for the
# container. Otherwize if not possible an ARP proxy could be set on the SGi next hop that is the 
# default gw 
DEFAULT_ROUTE=`ip route show table main | grep default`
DEFAULT_ROUTE_GW=`echo $DEFAULT_ROUTE | cut -d ' ' -f3`
DEFAULT_ROUTE_DEV=`echo $DEFAULT_ROUTE | cut -d ' ' -f5`
if [ $PGW_SGI_INTERFACE != $DEFAULT_ROUTE_DEV ] || [ $PGWU_SGI_GW != $DEFAULT_ROUTE_GW ] ; then
  echo "Removing route: $DEFAULT_ROUTE"
  ip route del $DEFAULT_ROUTE
  echo "Adding route: ip route add default via $PGWU_SGI_GW dev $PGW_SGI_INTERFACE"
  ip route add default via $PGWU_SGI_GW dev $PGW_SGI_INTERFACE
fi


exec "$@"
