# Use Ubuntu 17.04 as the base for our Rust musl toolchain.
FROM ubuntu:17.04

MAINTAINER Phil J. Łaszkowicz <phil@fillip.pro>

RUN apt-get update && apt-get install -y \
  cmake \
  curl \
  file \
  git \
  g++ \
  python \
  make \
  nano \
  ca-certificates \
  xz-utils \
  musl-tools \
  pkg-config \
  apt-file \
  xutils-dev \
  --no-install-recommends && \
  rm -rf /var/lib/apt/lists/*

RUN curl https://static.rust-lang.org/rustup.sh | sh -s -- \
  --with-target=x86_64-unknown-linux-musl \
  --yes \
  --disable-sudo \
  --channel=nightly && \
  mkdir /.cargo && \
  echo "[build]\ntarget = \"x86_64-unknown-linux-musl\"" > /.cargo/config

# Compile C libraries with musl-gcc
ENV SSL_VER=1.0.2k \
    CURL_VER=7.54.0 \
    CC=musl-gcc \
    PREFIX=/usr/local \
    PATH=/usr/local/bin:$PATH \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

RUN curl -sL http://www.openssl.org/source/openssl-$SSL_VER.tar.gz | tar xz && \
    cd openssl-$SSL_VER && \
    ./Configure no-shared --prefix=$PREFIX --openssldir=$PREFIX/ssl no-zlib linux-x86_64 -fPIC && \
    make depend 2> /dev/null && make -j$(nproc) && make install && \
    cd .. && rm -rf openssl-$SSL_VER

RUN curl https://curl.haxx.se/download/curl-$CURL_VER.tar.gz | tar xz && \
    cd curl-$CURL_VER && \
    ./configure --enable-shared=no --enable-static=ssl --enable-optimize --prefix=$PREFIX \
      --with-ca-path=/etc/ssl/certs/ --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt --without-ca-fallback && \
    make -j$(nproc) && make install && \
    cd .. && rm -rf curl-$CURL_VER

# SSL cert directories get overridden by --prefix and --openssldir
# and they do not match the typical host configurations.
# The SSL_CERT_* vars fix this, but only when inside this container
# musl-compiled binary must point SSL at the correct certs (muslrust/issues/5) elsewhere
# OPENSSL_ vars are backwards compat with older rust-openssl and are not needed with new versions of it
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    SSL_CERT_DIR=/etc/ssl/certs \
    OPENSSL_LIB_DIR=$PREFIX/lib \
    OPENSSL_INCLUDE_DIR=$PREFIX/include \
    OPENSSL_DIR=$PREFIX \
    OPENSSL_STATIC=1
