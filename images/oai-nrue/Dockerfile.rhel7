ARG REGISTRY=localhost
FROM $REGISTRY/oai-build-base:latest.el7 AS builder

ARG GIT_TAG=develop-nr

WORKDIR /root

RUN if [ "$EURECOM_PROXY" == true ]; then git config --global http.proxy http://:@proxy.eurecom.fr:8080; fi

RUN git clone --depth=1 --branch=$GIT_TAG https://gitlab.eurecom.fr/oai/openairinterface5g.git
COPY patches patches/
RUN patch -p1 -d openairinterface5g < patches/disable_building_nasmesh_rbtools_ue_ip.patch
RUN cd openairinterface5g/cmake_targets \
    && ln -sf /usr/local/bin/asn1c_oai /usr/local/bin/asn1c \
    && ln -sf /usr/local/share/asn1c_oai /usr/local/share/asn1c \
    && ./build_oai --nrUE -w USRP --verbose-compile


FROM registry.redhat.io/ubi7/ubi
LABEL name="oai-nrue" \
      version="$GIT_TAG" \
      maintainer="Frank A. Zdarsky <fzdarsky@redhat.com>" \
      io.k8s.description="openairinterface5g nrUE $GIT_TAG." \
      io.openshift.tags="oai,ue" \
      io.openshift.non-scalable="true"

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && REPOLIST="rhel-7-server-optional-rpms" \
    && PKGLIST="atlas blas boost lapack libconfig libusb libusbx libyaml lksctp-tools nettle protobuf-c iproute iputils procps-ng bind-utils xforms" \
    # && yum -y upgrade-minimal --setopt=tsflags=nodocs --security --sec-severity=Critical --sec-severity=Important \
    && yum -y install --enablerepo ${REPOLIST} --setopt=tsflag=nodocs ${PKGLIST} \
    && yum -y clean all \
    && rm -rf /var/cache/yum

ENV APP_ROOT=/opt/oai-nrue
ENV PATH=${APP_ROOT}:${PATH} HOME=${APP_ROOT}
COPY --from=builder /root/openairinterface5g/cmake_targets/ran_build/build/nr-uesoftmodem ${APP_ROOT}/bin/
COPY --from=builder /root/openairinterface5g/cmake_targets/ran_build/build/*.so* /lib64
COPY --from=builder /usr/local/lib64 /lib64
COPY --from=builder /usr/local/bin/uhd_* /usr/local/bin
COPY --from=builder /usr/local/share/uhd /usr/local/share/uhd
RUN cd /lib64 \
    && ln -sf liboai_eth_transpro.so liboai_transpro.so \
    && ln -sf liboai_usrpdevif.so liboai_device.so \
    && ln -sf libuhd.so.3.13 libuhd.so.3 \
    && ln -sf libuhd.so.3 libuhd.so
COPY scripts ${APP_ROOT}/bin/
RUN chmod -R u+x ${APP_ROOT} && \
    chgrp -R 0 ${APP_ROOT} && \
    chmod -R g=u ${APP_ROOT} /etc/passwd
USER 10001
WORKDIR ${APP_ROOT}

EXPOSE 2152/udp  # S1U, GTP/UDP
EXPOSE 22100/tcp # ?
EXPOSE 36412/udp # S1C, SCTP/UDP
EXPOSE 36422/udp # X2C, SCTP/UDP
EXPOSE 50000/udp # IF5 / ORI (control)
EXPOSE 50001/udp # IF5 / ECPRI (data)

CMD ["/opt/oai-gnb/bin/nr-uesoftmodem", "--numerology", "1", "-r", "106", "--phy-test", "-C", "3510000000"]
ENTRYPOINT ["/opt/oai-gnb/bin/entrypoint.sh"]
