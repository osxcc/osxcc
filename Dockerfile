FROM ubuntu:wily
MAINTAINER zchee <zchee.io@gmail.com>

# Install dependency package
# apt build-essential:             dpkg-dev g++ gcc libc-dev
# docker buildpack-deps:wily-curl: ca-certificates curl wget
# docker buildpack-deps:wily-scm:  git openssh-client
# docker buildpack-deps:wily:      automake autogen file
# osxcross dependencies:           clang-3.7 llvm-dev libxml2-dev uuid-dev libssl-dev bash patch make tar xz-utils bzip2 gzip sed cpio
# ?osxcross ld64 -bitcode_bundle:   libwxbase3.0-dev libwxgtk3.0-dev
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		dpkg-dev g++ gcc libc-dev \
		ca-certificates curl wget \
		git openssh-client \
		automake autogen file \
		clang-3.7 llvm-dev libxml2-dev uuid-dev libssl-dev bash patch make tar xz-utils bzip2 gzip sed cpio \
		libwxbase3.0-dev libwxgtk3.0-dev \
	&& rm -rf /var/lib/apt/lists/* \
	\
	&& ln -s /usr/bin/clang-3.7 /usr/bin/clang \
	&& ln -s /usr/bin/clang++-3.7 /usr/bin/clang++ \
	\
	&& git clone https://github.com/tpoechtrager/osxcross.git

ARG SDK_VERSION
ENV SDK_VERSION ${SDK_VERSION:-10.11}

ADD ./SDKs/MacOSX$SDK_VERSION.sdk.tar.xz /osxcross/tarballs/
RUN cd /osxcross/tarballs && \
        tar -cf - * | xz -9 -c - > MacOSX$SDK_VERSION.sdk.tar.xz && \
        rm -rf MacOSX$SDK_VERSION.sdk

RUN UNATTENDED=yes MACOSX_DEPLOYMENT_TARGET=$SDK_VERSION SDK_VERSION=$SDK_VERSION OSX_VERSION_MIN=$SDK_VERSION /osxcross/build.sh

ENV PATH /osxcross/target/bin:$PATH

RUN ls /bin/bash

CMD ["/bin/bash"]
