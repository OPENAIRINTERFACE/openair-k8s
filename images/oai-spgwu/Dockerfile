ARG REGISTRY=localhost
FROM $REGISTRY/oai-build-base:latest.el8 AS builder

ARG GIT_TAG=develop-vco3

WORKDIR /root

RUN git clone --depth=1 --branch=$GIT_TAG https://github.com/OPENAIRINTERFACE/openair-cn-cups.git
RUN git clone --depth=1 --branch=master https://github.com/gabime/spdlog.git openair-cn-cups/build/ext/spdlog
COPY patches patches/
RUN patch -p1 -d openair-cn-cups < patches/enable_sudo-less_build.patch
RUN cd openair-cn-cups/build/scripts \
    && ./build_spgwu -c -v -b RelWithDebInfo -j

FROM registry.redhat.io/ubi8/ubi
LABEL name="oai-spgwu" \
      version="$GIT_TAG" \
      maintainer="Frank A. Zdarsky <fzdarsky@redhat.com>" \
      io.k8s.description="openair-cn-cups S/P-GW-U $GIT_TAG" \
      io.openshift.tags="oai,spgwu" \
      io.openshift.non-scalable="true"

RUN REPOLIST=codeready-builder-for-rhel-8-x86_64-rpms \
    PKGLIST="boost libasan libconfig libevent gflags-devel glog-devel iproute iputils iptables procps-ng bind-utils" && \
    # yum -y update-minimal --setopt=tsflags=nodocs --security --sec-severity=Important --sec-severity=Critical && \
    yum -y install --enablerepo ${REPOLIST} --setopt=tsflag=nodocs ${PKGLIST} && \
    yum -y clean all

ENV APP_ROOT=/opt/oai-spgwu
ENV PATH=${APP_ROOT}:${PATH} HOME=${APP_ROOT}
COPY --from=builder /root/openair-cn-cups/build/spgw_u/build/spgwu ${APP_ROOT}/bin/
COPY scripts ${APP_ROOT}/bin/
COPY configs ${APP_ROOT}/etc/
RUN chmod -R u+x ${APP_ROOT} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd
#USER 10001
WORKDIR ${APP_ROOT}

# expose ports
EXPOSE 2152/udp 8805/udp

CMD ["/opt/oai-spgwu/bin/spgwu", "-c", "/opt/oai-spgwu/etc/spgw_u.conf", "-o"]
ENTRYPOINT ["/opt/oai-spgwu/bin/entrypoint.sh"]
