FROM ubuntu:wily
MAINTAINER zchee <k@zchee.io>

# Install dependency package
# apt build-essential:             dpkg-dev g++ gcc libc-dev
# docker buildpack-deps:wily-curl: ca-certificates curl wget
# docker buildpack-deps:wily-scm:  git openssh-client
# docker buildpack-deps:wily:      automake autogen file
# osxcross dependencies:           clang-3.7 llvm-dev libxml2-dev uuid-dev libssl-dev bash patch make tar xz-utils bzip2 gzip sed cpio
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
		clang-3.7 llvm-dev libxml2-dev uuid-dev libssl-dev bash patch make tar xz-utils bzip2 gzip sed cpio \
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
	&& mkdir -p /osxcross/darwin/bin \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-ObjectDump /osxcross/darwin/bin/ObjectDump \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-ar /osxcross/darwin/bin/ar \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-as /osxcross/darwin/bin/as \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-bitcode_strip /osxcross/darwin/bin/bitcode_strip \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/c++ \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/cc \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-checksyms /osxcross/darwin/bin/checksyms \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/clang \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/clang++ \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/clang++-gstdc++ \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/clang++-stdc++ \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-codesign_allocate /osxcross/darwin/bin/codesign_allocate \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/dsymutil \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-dyldinfo /osxcross/darwin/bin/dyldinfo \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-indr /osxcross/darwin/bin/indr \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-install_name_tool /osxcross/darwin/bin/install_name_tool \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-ld /osxcross/darwin/bin/ld \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-libtool /osxcross/darwin/bin/libtool \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-lipo /osxcross/darwin/bin/lipo \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-machocheck /osxcross/darwin/bin/machocheck \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-nm /osxcross/darwin/bin/nm \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-nmedit /osxcross/darwin/bin/nmedit \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/osxcross \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/osxcross-cmp \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/osxcross-conf \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/osxcross-env \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/osxcross-man \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-otool /osxcross/darwin/bin/otool \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-pagestuff /osxcross/darwin/bin/pagestuff \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/pkg-config \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-ranlib /osxcross/darwin/bin/ranlib \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-redo_prebinding /osxcross/darwin/bin/redo_prebinding \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-seg_addr_table /osxcross/darwin/bin/seg_addr_table \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-seg_hack /osxcross/darwin/bin/seg_hack \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-segedit /osxcross/darwin/bin/segedit \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-size /osxcross/darwin/bin/size \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-strings /osxcross/darwin/bin/strings \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-strip /osxcross/darwin/bin/strip \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/sw_vers \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-unwinddump /osxcross/darwin/bin/unwinddump \
	&& ln -s /osxcross/target/bin/x86_64-apple-darwin15-wrapper /osxcross/darwin/bin/xcrun

CMD ["/bin/bash"]
