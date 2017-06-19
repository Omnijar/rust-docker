FROM debian:stretch

MAINTAINER Phil J. Łaszkowicz <phil@fillip.pro>

# The Rust toolchain to use when building our image.  Set by `hooks/build`.
ARG TOOLCHAIN=stable

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    autoconf \
    automake \
    autotools-dev \
    build-essential \
    ca-certificates \
    curl \
    file \
    libtool \
    xutils-dev 

# set openssl version
ENV SSL_VERSION=1.0.2l

# get openssl version for building against
RUN curl https://www.openssl.org/source/openssl-$SSL_VERSION.tar.gz -O && \
    tar -xzf openssl-$SSL_VERSION.tar.gz && \
    cd openssl-$SSL_VERSION && \
       ./config && \
       make depend && \
       make install && \
    cd .. && rm -rf openssl-$SSL_VERSION*

ENV OPENSSL_LIB_DIR=/usr/local/ssl/lib \
    OPENSSL_INCLUDE_DIR=/usr/local/ssl/include \
    OPENSSL_STATIC=1

# install rustup toolchain
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain $TOOLCHAIN -y

# set cargo path
ENV PATH=/root/.cargo/bin:$PATH

# musl tools
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    musl-tools 

# install musl target
RUN rustup target add x86_64-unknown-linux-musl && \
    rustup target add i686-unknown-linux-musl \
    --toolchain $TOOLCHAIN-x86_64-unknown-linux-gnu

# make default target to musl
RUN mkdir /.cargo
ADD cargo-config.toml /.cargo/config

# clean up
RUN apt-get remove -y --purge \
    curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*