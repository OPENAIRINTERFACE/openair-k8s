FROM localhost/oai-build-base AS builder

ARG GIT_TAG=develop-nr-2019w28

WORKDIR /root

RUN git clone --depth=1 --branch=$GIT_TAG https://gitlab.eurecom.fr/oai/openairinterface5g.git
RUN cd openairinterface5g/cmake_targets \
    && ln -sf /usr/local/bin/asn1c_oai /usr/local/bin/asn1c \
    && ln -sf /usr/local/share/asn1c_oai /usr/local/share/asn1c \
    && ./build_oai --gNB -w USRP --verbose-compile


FROM registry.redhat.io/ubi8/ubi
LABEL name="oai-gnb" \
      version="$GIT_TAG" \
      maintainer="Frank A. Zdarsky <fzdarsky@redhat.com>" \
      io.k8s.description="openairinterface5g gNB $GIT_TAG." \
      io.openshift.tags="oai,gnb" \
      io.openshift.non-scalable="true"

RUN REPOLIST=codeready-builder-for-rhel-8-x86_64-rpms \
    PKGLIST="atlas blas lapack libconfig lksctp-tools protobuf-c iproute iputils procps-ng bind-utils" && \
    # yum -y upgrade-minimal --setopt=tsflags=nodocs --security --sec-severity=Critical --sec-severity=Important && \
    yum -y install --enablerepo ${REPOLIST} --setopt=tsflag=nodocs ${PKGLIST} && \
    yum install -y http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/x/xforms-1.2.4-5.el7.x86_64.rpm && \
    yum -y clean all

ENV APP_ROOT=/opt/oai-gnb
ENV PATH=${APP_ROOT}:${PATH} HOME=${APP_ROOT}
COPY --from=builder /root/openairinterface5g/cmake_targets/ran_build/build/nr-softmodem ${APP_ROOT}/bin/
RUN chmod -R u+x ${APP_ROOT} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd
USER 10001
WORKDIR ${APP_ROOT}

# expose ports
# EXPOSE 3868/tcp 5868/tcp

CMD ["-h"]
ENTRYPOINT ["${APP_ROOT}/bin/nr-softmodem"]
