#! /bin/bash

#Copyright (c) 2017 Sprint
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

### Add an entry to the mme_identity table ######

id=$1
isdn=$2
host=$3
realm=$4
uereachability=$5
cassandra_ip=$6
if [ "$*" == "" -o $# -ne 6 ] ; then
   echo -e "You must provide all of the arguments to the script\n"
   echo -e "$0 <id> <isdn> <host> <realm> <uereachability> <cassandra_ip>\n"
   exit
fi

cqlsh $cassandra_ip -e "INSERT INTO vhss.mmeidentity (idmmeidentity, mmeisdn, mmehost, mmerealm, ue_reachability) VALUES ($id, '$isdn', '$host', '$realm', $uereachability);"
if [ $? -ne 0 ];then
   echo -e "Oops! Something went wrong adding to vhss.mmeidentity!\n"
   exit
fi

cqlsh $cassandra_ip -e "INSERT INTO vhss.mmeidentity_host (idmmeidentity, mmeisdn, mmehost, mmerealm, ue_reachability) VALUES ($id, '$isdn', '$host', '$realm', $uereachability);"
if [ $? -ne 0 ];then
   echo -e "Oops! Something went wrong adding to vhss.mmeidentity_host!\n"
   exit
fi

echo -e "The mmeidentity provisioning is successfull\n"
