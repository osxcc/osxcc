FROM ubuntu:wily
MAINTAINER zchee <k@zchee.io>

# Install dependency package
# apt build-essential:             dpkg-dev g++ gcc libc-dev
# docker buildpack-deps:wily-curl: ca-certificates curl wget
# docker buildpack-deps:wily-scm:  git openssh-client
# docker buildpack-deps:wily:      automake autogen file
# osxcross dependencies:           clang-3.7 llvm-3.7-dev libxml2-dev uuid-dev libssl-dev bash patch make tar xz-utils bzip2 gzip sed cpio
# ?osxcross ld64 -bitcode_bundle:  libwxbase3.0-dev libwxgtk3.0-dev
# sudo:                            for OS X compatible

ARG SDK_VERSION
ARG XCODE_VERSION

ENV PATH=/osxcross/darwin/bin:/osxcross/target/bin:$PATH \
	SDK_VERSION=${SDK_VERSION:-1011} \
	XCODE_VERSION=${XCODE_VERSION:-72_7C68}

COPY ./SDKs/MacOSX${SDK_VERSION}.sdk.Xcode${XCODE_VERSION}.tar.xz /

RUN set -ex \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		dpkg-dev g++ gcc libc-dev \
		ca-certificates curl wget \
		git openssh-client \
		automake autogen file \
		clang-3.7 llvm-3.7-dev libxml2-dev uuid-dev libssl-dev bash patch make tar xz-utils bzip2 gzip sed cpio \
		libwxbase3.0-dev libwxgtk3.0-dev \
		sudo \
	&& rm -rf /var/lib/apt/lists/* \
	\
	&& ln -s /usr/bin/clang-3.7 /usr/bin/clang \
	&& ln -s /usr/bin/clang++-3.7 /usr/bin/clang++ \
	\
	&& groupadd wheel \
	&& usermod -G wheel root \
	\
	&& git clone https://github.com/tpoechtrager/osxcross.git \
	&& mv /MacOSX${SDK_VERSION}.sdk.Xcode${XCODE_VERSION}.tar.xz /osxcross/tarballs/MacOSX10.11.sdk.tar.xz \
	\
	&& UNATTENDED=yes MACOSX_DEPLOYMENT_TARGET=10.11 SDK_VERSION=10.11 OSX_VERSION_MIN=10.11 JOBS=$(($(nproc)+1)) /osxcross/build.sh \
	\
	&& mkdir -p /osxcross/darwin/bin

CMD ["/bin/bash"]
