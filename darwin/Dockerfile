FROM omnijarstudio/rust

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

# install musl target
RUN rustup target add i686-apple-darwin && \
    rustup target add x86_64-apple-darwin

# clean up
RUN apt-get remove -y --purge \
    curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*