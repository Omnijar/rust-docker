FROM debian:stretch

MAINTAINER Phil J. Łaszkowicz <phil@fillip.pro>

# The Rust toolchain to use when building our image.  Set by `hooks/build`.
ARG TOOLCHAIN=stable

WORKDIR /root

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
    xutils-dev 

# install rustup toolchain
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain $TOOLCHAIN -y

# set cargo path
ENV PATH=/root/.cargo/bin:$PATH

# install musl target
RUN rustup target add i686-pc-windows-gnu &&  \
    rustup target add i686-pc-windows-msvc && \
    rustup target add x86_64-pc-windows-gnu && \
    rustup target add x86_64-pc-windows-msvc

# clean up
RUN apt-get remove -y --purge \
    curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*