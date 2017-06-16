# Rust Docker container for easily building static Rust binaries

[![Docker Image](https://img.shields.io/docker/pulls/omnijarstudio/rust.svg?maxAge=2592000)](https://hub.docker.com/r/omnijarstudio/rust/)

Public trusted images available on:

* [Docker Hub](https://hub.docker.com/r/omnijarstudio/rust/)
* [Quay.io](https://quay.io/repository/omnijarstudio/rust)

This repository is used to build a Docker image for the 
Rust programming language and a few supporting tools. The 
image includes `rustc`, `rustdoc`, `cargo`, `git`, SSL 
certificates, and build essentials, so it should be able 
to run `cargo build` on most projects out of the box. T
he path `/source` is a volume where you can mount a 
Cargo project from the host machine.

### Usage

The following command will drop you into a Bash shell with the 
current directory on the host shared. From there you can run 
`rustc`, `rustdoc`, and `cargo` as you please.

``` bash
docker run -it --rm -v $(pwd):/source omnijarstudio/rust
```

## Building for musl

### Without dependencies

```sh
alias rust-musl-builder='docker run --rm -it -v "$(pwd)":/home/rust/src omnijarstudio/rust'
omnijar-rust cargo build --release
```

This command assumes that `$(pwd)` is readable and writable by uid 1000,
gid 1000.  It will output binaries in
`target/x86_64-unknown-linux-musl/release`. At the moment, it doesn't
attempt to cache libraries between builds, so this is best reserved for
making final release builds.

### Deploying your Rust application

With a bit of luck, you should be able to just copy your application binary
from `target/x86_64-unknown-linux-musl/release`, and install it directly on
any reasonably modern x86_64 Linux machine.  In particular, you should be
able to copy your Rust application into an
[Alpine Linux container][].

### How it works

`rust-musl-builder` uses [musl-libc][], [musl-gcc][], and the new
[rustup][] `target` support.  It includes static versions of several
libraries:

- The standard `musl-libc` libraries.
- OpenSSL, which is needed by many Rust applications.

### Adding more C libraries

If you're using Docker crates which require specific C libraries to be
installed, you can create a Dockerfile based on this one, and use
`musl-gcc` to compile the libraries you need.  For example:

```Dockerfile
FROM omnijarstudio/rust:musl

RUN VERS=1.2.8 && \
    cd /home/rust/libs && \
    curl -LO http://zlib.net/zlib-$VERS.tar.gz && \
    tar xzf zlib-$VERS.tar.gz && cd zlib-$VERS && \
    CC=musl-gcc ./configure --static --prefix=/usr/local/musl && \
    make && sudo make install && \
    cd .. && rm -rf zlib-$VERS.tar.gz zlib-$VERS
```

This usually involves a bit of experimentation for each new library, but it
seems to work well for most simple, standalone libraries.

If you need an especially common library, please feel free to submit a pull
request adding it to the main `Dockerfile`!  We'd like to support popular
Rust crates out of the box.

### Making static releases with Travis CI and GitHub

These instructions are inspired by [rust-cross][].

First, read the [Travis CI: GitHub Releases Uploading][uploading] page, and
run `travis setup releases` as instructed.  Then add the following lines to
your existing `.travis.yml` file, replacing `myapp` with the name of your
package:

```yaml
language: rust
sudo: required
os:
- linux
- osx
rust:
- stable
services:
- docker
before_deploy: "./build-release myapp ${TRAVIS_TAG}-${TRAVIS_OS_NAME}"
deploy:
  provider: releases
  api_key:
    secure: "..."
  file_glob: true
  file: "myapp-${TRAVIS_TAG}-${TRAVIS_OS_NAME}.*"
  skip_cleanup: true
  on:
    rust: stable
    tags: true
```

Next, copy [`build-release`](./examples/build-release) into your project
and run `chmod +x build-release`.

When you push a new tag to your project, `build-release` will automatically
build new Linux binaries using the Omnijar Rust builder, and new Mac binaries
with Cargo, and it will upload both to the GitHub releases page for your
repository.

For a working example, see [faradayio/conductor][conductor].

[rust-cross]: https://github.com/japaric/rust-cross
[uploading]: https://docs.travis-ci.com/user/deployment/releases
[conductor]: https://github.com/faradayio/conductor

## License

[MIT license](./LICENSE-MIT.txt).

[Alpine Linux container]: https://hub.docker.com/_/alpine/
[musl-libc]: http://www.musl-libc.org/
[musl-gcc]: http://www.musl-libc.org/how.html
[rustup]: https://www.rustup.rs/
