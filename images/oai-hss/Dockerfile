ARG REGISTRY=localhost
FROM $REGISTRY/oai-build-base:latest.el8 AS builder

ARG GIT_TAG=develop-vco3

WORKDIR /root

RUN git clone --depth=1 --branch=$GIT_TAG https://github.com/OPENAIRINTERFACE/openair-cn.git
COPY patches patches/
RUN patch -p1 -d openair-cn < patches/enable_sudo-less_build.patch \
    && patch -p1 -d openair-cn < patches/disable_distro_check_and_rpm_install.patch \
    && patch -p1 -d openair-cn < patches/fix_libpistache_lib_path.patch
RUN cd openair-cn/scripts \
    && ln -sf /usr/local/bin/asn1c_cn /usr/local/bin/asn1c \
    && ln -sf /usr/local/share/asn1c_cn /usr/local/share/asn1c \
    && rm -rf /usr/local/lib/freeDiameter /usr/local/lib/libfd* \
    && OPENAIRCN_DIR=$(dirname $(pwd)) ./build_hss_rel14 --check-installed-software --force \
    && OPENAIRCN_DIR=$(dirname $(pwd)) ./build_hss_rel14 -v


FROM registry.redhat.io/ubi8/ubi
LABEL name="oai-hss" \
      version="$GIT_TAG" \
      maintainer="Frank A. Zdarsky <fzdarsky@redhat.com>" \
      io.k8s.description="openair-cn HSS $GIT_TAG." \
      io.openshift.tags="oai,hss" \
      io.openshift.non-scalable="true" \
      io.openshift.wants="mariadb"

RUN REPOLIST=codeready-builder-for-rhel-8-x86_64-rpms \
    PKGLIST="libconfig libidn mariadb-devel lksctp-tools mysql iproute iputils procps-ng bind-utils" && \
    # yum -y upgrade-minimal --setopt=tsflags=nodocs --security --sec-severity=Critical --sec-severity=Important && \
    yum -y install --enablerepo ${REPOLIST} --setopt=tsflag=nodocs ${PKGLIST} && \
    yum -y clean all

ENV APP_ROOT=/opt/oai-hss
ENV PATH=${APP_ROOT}:${PATH} HOME=${APP_ROOT}

COPY --from=builder /root/openair-cn/build/hss_rel14/bin/hss ${APP_ROOT}/bin/oai_hss
COPY --from=builder /usr/local/lib/libfd* /lib64
COPY --from=builder /usr/local/lib/freeDiameter/* /usr/local/lib/freeDiameter/
COPY --from=builder /usr/local/lib64/libcassandra* /lib64
COPY --from=builder /usr/local/lib64/libuv.so /lib64
COPY scripts ${APP_ROOT}/bin/
COPY configs ${APP_ROOT}/etc/
RUN chmod -R u+x ${APP_ROOT} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd
USER 10001
WORKDIR ${APP_ROOT}

# expose ports configured in hss_fd.conf
EXPOSE 9042/tcp 5868/tcp 9080/tcp 9081/tcp

VOLUME ["${APP_ROOT}/certs"]

CMD ["/opt/oai-hss/bin/oai_hss", "-j", "/opt/oai-hss/etc/hss_rel14.json"]
ENTRYPOINT ["/opt/oai-hss/bin/entrypoint.sh"]
