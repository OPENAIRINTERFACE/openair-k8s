#!/bin/bash

CASS_CONTAINER_NAME=${CASS_CONTAINER_NAME:-cassandra}
CASS_CONTAINER_IP=`sudo podman exec -it $CASS_CONTAINER_NAME ip -4 addr show  scope global | awk '$1 == "inet" {print $2}' | xargs | cut -d '/' -f1`
SCRIPT=$(readlink -f $0)
THIS_SCRIPT_PATH=`dirname $SCRIPT`
CQL_FILE=$THIS_SCRIPT_PATH/../db/oai_db.cql

info() {
    local MESSAGE=$1
    echo -e "\E[34m\n== $MESSAGE\E[00m";
}

usage() {
    echo "Set OAI schema in cassandra DB.
    
usage: $(basename $0) [-h] [-c 'cql filename'] [-n 'cassandra container name'] [-i 'cassandra reachable ip']
  -c|--cql-file :       Filesystem path of the cql that will populate the cassandra DB, default is $CQL_FILE
  -n|--container-name : Name of the cassandra container, default is $CASS_CONTAINER_NAME
  -i|--ip :             IP address of the cassandra container, default is $CASS_CONTAINER_IP
  -h|--help:            Prints this help message"
    exit 1
}

# parse command line args
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
        usage
        ;;
        -c|--cql-file)
        $CQL_FILE="$2"
        shift 2
        ;;
        -n|--container-name)
        CASS_CONTAINER_NAME="$2"
        shift 2
        ;;
        -i|--ip)
        CASS_CONTAINER_IP="$2"
        shift 2
        ;;
        *) # unknown option
        usage
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

info "container-name:  $CASS_CONTAINER_NAME"
info "ip:              $CASS_CONTAINER_IP"
info "cql-file:        $CQL_FILE"
CQL="`cat $CQL_FILE`"
sudo podman exec -it  $CASS_CONTAINER_NAME cqlsh $CASS_CONTAINER_IP -e "$CQL"
