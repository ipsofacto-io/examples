# The Atlantis image plus a verified ipso release.
FROM ghcr.io/runatlantis/atlantis:v0.49.0@sha256:389f1c1bf12bd08d647f0383b13cd531e5667a6c654adadf4932d6bf4d5e0c13

ARG TARGETARCH

USER root
RUN set -eu; \
    version=0.3.0; \
    case "${TARGETARCH}" in \
      amd64) checksum=8dbb29e0db4ed8f52bd7cd27c1015df122a854597e6aa40ed183e4850c2acdcb ;; \
      arm64) checksum=28e24cfaaf53e7b622e34f18a5ac60b933eb9884c7c7b0e1e99909f61291ba2d ;; \
      *) echo "no ipso release for ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    archive="ipso_${version}_linux_${TARGETARCH}.tar.gz"; \
    wget -q -O "/tmp/${archive}" "https://github.com/ipsofacto-io/ipso/releases/download/v${version}/${archive}"; \
    echo "${checksum}  /tmp/${archive}" | sha256sum -c -; \
    tar -xzf "/tmp/${archive}" -C /usr/local/bin ipso; \
    rm "/tmp/${archive}"
USER atlantis
