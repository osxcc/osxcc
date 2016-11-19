FROM ubuntu:xenial
MAINTAINER zchee <k@zchee.io>

# Install dependency package
# apt build-essential:             dpkg-dev g++ gcc libc-dev
# docker buildpack-deps:wily-curl: ca-certificates curl wget
# docker buildpack-deps:wily-scm:  git openssh-client
# docker buildpack-deps:wily:      automake autogen file
# osxcross dependencies:           clang-$LLVM_VERSION llvm-$LLVM_VERSION-dev lldb-$LLVM_VERSION-dev libxml2-dev uuid-dev libssl-dev bash patch make tar xz-utils bzip2 gzip sed cpio
# ?osxcross ld64 -bitcode_bundle:  libwxbase3.0-dev libwxgtk3.0-dev
# sudo:                            for OS X compatible

# allow replacing httpredir mirror
ARG APT_MIRROR=0
# macOS SDK version
ARG SDK_VERSION=10.11
ARG XCODE_VERSION=7.3.1_7D1014
# llvm and clang version
ARG LLVM_VERSION=3.8
# debug for osxcross
ARG OCDEBUG

ENV PATH=/osxcross/darwin/bin:/osxcross/target/bin:$PATH

COPY ./SDKs/MacOSX${SDK_VERSION}.sdk.Xcode${XCODE_VERSION}.tar.xz /

RUN set -ex \
	&& if [ "${APT_MIRROR}" = "1" ]; then sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//mirror:\/\/mirrors.ubuntu.com\/mirrors.txt/g' /etc/apt/sources.list; fi \
	&& sed -i 's/deb-src/# deb-src/g' /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		ca-certificates curl wget \
	&& \
		if [ "${LLVM_VERSION}" = "4.0" ]; then \
			echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial main" >> /etc/apt/sources.list; \
		else \
			echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-${LLVM_VERSION} main" >> /etc/apt/sources.list; \
		fi \
	&& curl http://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - \
	\
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		dpkg-dev g++ gcc libc-dev \
		git openssh-client \
		automake autogen file \
		clang-${LLVM_VERSION} llvm-${LLVM_VERSION}-dev lldb-${LLVM_VERSION} \
		libxml2-dev uuid-dev libssl-dev bash patch make tar xz-utils bzip2 gzip sed cpio \
		libwxbase3.0-dev libwxgtk3.0-dev \
		sudo \
	&& rm -rf /var/lib/apt/lists/* \
	\
	&& ln -s /usr/bin/clang-${LLVM_VERSION} /usr/bin/clang \
	&& ln -s /usr/bin/clang++-${LLVM_VERSION} /usr/bin/clang++ \
	&& ln -s /usr/bin/llvm-config-${LLVM_VERSION} /usr/bin/llvm-config \
	&& ln -s /usr/lib/x86_64-linux-gnu/libclang-${LLVM_VERSION}.so /usr/lib/x86_64-linux-gnu/libclang.so \
	\
	&& groupadd wheel \
	&& usermod -G wheel root \
	\
	&& git clone https://github.com/tpoechtrager/osxcross.git \
	&& mv /MacOSX${SDK_VERSION}.sdk.Xcode${XCODE_VERSION}.tar.xz /osxcross/tarballs/MacOSX${SDK_VERSION}.sdk.tar.xz \
	\
	&& UNATTENDED=yes MACOSX_DEPLOYMENT_TARGET=${SDK_VERSION} SDK_VERSION=${SDK_VERSION} OSX_VERSION_MIN=${SDK_VERSION} JOBS=$(($(nproc)+1)) /osxcross/build.sh \

CMD ["/bin/bash"]
