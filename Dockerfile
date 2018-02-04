FROM debian:stretch

MAINTAINER Phil J. Łaszkowicz <phil@fillip.pro>

# The Rust toolchain to use when building our image.  Set by `--build-arg`.
ARG TOOLCHAIN=stable

# build packages
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
    musl-tools \
    sudo \
    xutils-dev

RUN useradd rust --user-group --create-home --shell /bin/bash --groups sudo

# Allow sudo without a password.
ADD linux/musl/sudoers /etc/sudoers.d/nopasswd
RUN chmod -R 0755 /etc/sudoers.d

# Run all further code as user `rust`, and create our working directories
# as the appropriate user.
USER rust
RUN mkdir -p /home/rust/libs /home/rust/src

# Set up our path with all our binary directories, including those for the
# musl-gcc toolchain and for our Rust toolchain.
ENV PATH=/home/rust/.cargo/bin:/usr/local/musl/bin:/usr/local/bin:/usr/bin:/bin

# Install our Rust toolchain and the `musl` target.  We patch the
# command-line we pass to the installer so that it won't attempt to
# interact with the user or fool around with TTYs.  We also set the default
# `--target` to musl so that our users don't need to keep overriding it
# manually.
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- -y --default-toolchain $TOOLCHAIN && \
    rustup target add x86_64-unknown-linux-musl && \
    rustup target add i686-unknown-linux-musl && \
    rustup target add i686-unknown-linux-gnu && \
    rustup target add i686-pc-windows-gnu &&  \
    rustup target add i686-pc-windows-msvc && \
    rustup target add x86_64-pc-windows-gnu && \
    rustup target add x86_64-pc-windows-msvc && \
    rustup target add i686-apple-darwin && \
    rustup target add x86_64-apple-darwin \
    --toolchain $TOOLCHAIN-x86_64-unknown-linux-gnu
ADD linux/musl/cargo-config.toml /home/rust/.cargo/config

# We'll build our libraries in subdirectories of /home/rust/libs.  Please
# clean up when you're done.
WORKDIR /home/rust/libs

# set openssl version
ENV SSL_VERSION=1.0.2l

# Build a static library version of OpenSSL using musl-libc.  This is
# needed by the popular `rust-openssl` crate.
RUN curl -O https://www.openssl.org/source/openssl-$SSL_VERSION.tar.gz && \
    tar xvzf openssl-$SSL_VERSION.tar.gz && cd openssl-$SSL_VERSION && \
    env CC=musl-gcc ./config --prefix=/usr/local/musl && \
    env C_INCLUDE_PATH=/usr/local/musl/include/ && \
    make depend && \
    make && \
    sudo make install && \
    cd .. && \
    rm -rf openssl-$SSL_VERSION.tar.gz openssl-$SSL_VERSION

ENV OPENSSL_DIR=/usr/local/musl/ \
    OPENSSL_INCLUDE_DIR=/usr/local/musl/include/ \
    DEP_OPENSSL_INCLUDE=/usr/local/musl/include/ \
    OPENSSL_LIB_DIR=/usr/local/musl/lib/ \
    OPENSSL_STATIC=1

# clean up
RUN sudo apt-get remove -y --purge \
    curl && \
    sudo apt-get autoremove -y && \
    sudo rm -rf /var/lib/apt/lists/*

# Expect our source code to live in /home/rust/src.  We'll run the build as
# user `rust`, which will be uid 1000, gid 1000 outside the container.
WORKDIR /home/rust/src
