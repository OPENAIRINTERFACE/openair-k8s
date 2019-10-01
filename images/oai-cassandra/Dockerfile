# vim:set ft=dockerfile:
FROM cassandra:3.11

# Just to have a tag for build_images script
ARG GIT_TAG=master


LABEL name="oai-cassandra" \
      version="$GIT_TAG" \
      maintainer="Frank A. Zdarsky <fzdarsky@redhat.com>" \
      io.k8s.description="openair-cn Cassandra DB $GIT_TAG." \
      io.openshift.tags="oai,hss,db" \
      io.openshift.non-scalable="true"
      
COPY configs/cassandra.yaml "$CASSANDRA_CONFIG"
RUN mkdir -m 0777 -p /opt/oai_db
COPY configs/oai_db.cql /opt/oai_db
RUN mkdir -m 0777 -p /opt/bin
COPY ./scripts/data_provisioning_mme.sh /opt/bin
COPY ./scripts/data_provisioning_users.sh /opt/bin

