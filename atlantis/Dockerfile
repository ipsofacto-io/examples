# The Atlantis image plus a verified ipso release.
FROM ghcr.io/runatlantis/atlantis:v0.49.0@sha256:389f1c1bf12bd08d647f0383b13cd531e5667a6c654adadf4932d6bf4d5e0c13

ARG TARGETARCH

USER root
RUN set -eu; \
    version=0.4.0; \
    case "${TARGETARCH}" in \
      amd64) checksum=632511629b3f8bbb01defba4156638177c454da951baf216fb70a0cc1350ab60 ;; \
      arm64) checksum=af7a23a266e580efe01b8a81d5e77757fb27d789c2c02400382fe8f7de4b5786 ;; \
      *) echo "no ipso release for ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    archive="ipso_${version}_linux_${TARGETARCH}.tar.gz"; \
    wget -q -O "/tmp/${archive}" "https://github.com/ipsofacto-io/ipso/releases/download/v${version}/${archive}"; \
    echo "${checksum}  /tmp/${archive}" | sha256sum -c -; \
    tar -xzf "/tmp/${archive}" -C /usr/local/bin ipso; \
    rm "/tmp/${archive}"
USER atlantis
