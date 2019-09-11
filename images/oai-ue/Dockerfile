FROM localhost/oai-build-base AS builder

ARG GIT_TAG=v1.0.3

WORKDIR /root

RUN git clone --depth=1 --branch=$GIT_TAG https://gitlab.eurecom.fr/oai/openairinterface5g.git
RUN mkdir -p /lib/modules/$(uname -r) && ln -s $(find /usr/src/kernels -type d -name "4\.18.*" | head -n 1) /lib/modules/$(uname -r)/build
COPY patches patches/
RUN patch -p1 -d openairinterface5g < patches/el8_support_ue_ip_module.patch
RUN cd openairinterface5g/cmake_targets \
    && ln -sf /usr/local/bin/asn1c_oai /usr/local/bin/asn1c \
    && ln -sf /usr/local/share/asn1c_oai /usr/local/share/asn1c \
    && ./build_oai -c --UE -w USRP --ue-nas-use-tun --verbose-compile


FROM registry.redhat.io/ubi8/ubi
LABEL name="oai-ue" \
      version="$GIT_TAG" \
      maintainer="Frank A. Zdarsky <fzdarsky@redhat.com>" \
      io.k8s.description="openairinterface5g UE $GIT_TAG." \
      io.openshift.tags="oai,ue" \
      io.openshift.non-scalable="true"

RUN REPOLIST=codeready-builder-for-rhel-8-x86_64-rpms \
    PKGLIST="atlas blas lapack libconfig lksctp-tools protobuf-c iproute iputils procps-ng bind-utils" && \
    # yum -y upgrade-minimal --setopt=tsflags=nodocs --security --sec-severity=Critical --sec-severity=Important && \
    yum -y install --enablerepo ${REPOLIST} --setopt=tsflag=nodocs ${PKGLIST} && \
    yum install -y http://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/x/xforms-1.2.4-5.el7.x86_64.rpm && \
    yum -y clean all

ENV APP_ROOT=/opt/oai-gnb
ENV PATH=${APP_ROOT}:${PATH} HOME=${APP_ROOT}
COPY --from=builder /root/openairinterface5g/cmake_targets/lte_build_oai/build/lte-uesoftmodem ${APP_ROOT}/bin/
RUN chmod -R u+x ${APP_ROOT} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd
USER 10001
WORKDIR ${APP_ROOT}

# expose ports
# EXPOSE 3868/tcp 5868/tcp

CMD ["-h"]
ENTRYPOINT ["${APP_ROOT}/bin/lte-uesoftmodem"]
