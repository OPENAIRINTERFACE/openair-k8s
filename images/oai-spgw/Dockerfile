FROM localhost/oai-build-base AS builder

ARG GIT_TAG=v1.0.1

WORKDIR /root

RUN git clone --depth=1 --branch=$GIT_TAG https://github.com/OPENAIRINTERFACE/openair-cn.git
COPY patches patches/
RUN patch -p1 -d openair-cn < patches/enable_sudo-less_build.patch \
    && patch -p1 -d openair-cn < patches/fix_openflow_compile_issue.patch
RUN cd openair-cn/scripts \
    && ln -sf /usr/local/bin/asn1c_cn /usr/local/bin/asn1c \
    && ln -sf /usr/local/share/asn1c_cn /usr/local/share/asn1c \
    && OPENAIRCN_DIR=$(dirname $(pwd)) ./build_spgw -v


FROM registry.redhat.io/ubi8/ubi
LABEL name="oai-spgw" \
      version="$GIT_TAG" \
      maintainer="Frank A. Zdarsky <fzdarsky@redhat.com>" \
      io.k8s.description="openair-cn S/P-GW $GIT_TAG" \
      io.openshift.tags="oai,spgw" \
      io.openshift.non-scalable="true"

RUN REPOLIST=codeready-builder-for-rhel-8-x86_64-rpms \
    PKGLIST="libasan libconfig libevent iproute iputils procps-ng bind-utils" && \
    # yum -y upgrade-minimal --setopt=tsflags=nodocs --security --sec-severity=Critical --sec-severity=Important && \
    yum -y install --enablerepo ${REPOLIST} --setopt=tsflag=nodocs ${PKGLIST} && \
    yum -y clean all

ENV APP_ROOT=/opt/oai-spgw
ENV PATH=${APP_ROOT}:${PATH} HOME=${APP_ROOT}
COPY --from=builder /root/openair-cn/build/spgw/build/spgw ${APP_ROOT}/bin/
COPY --from=builder /usr/local/lib/liblfds* /usr/lib64
RUN chmod -R u+x ${APP_ROOT} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd
USER 10001
WORKDIR ${APP_ROOT}

# expose ports
# EXPOSE 3868/tcp 5868/tcp

CMD ["-h"]
ENTRYPOINT ["${APP_ROOT}/bin/spgw"]
