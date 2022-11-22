FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LLVM_VERSION=14.0.6

RUN apt-get update -qqy && \
    apt-get install -qqy \
      bzip2 \
      clang \
      clang-format \
      clang-tidy \
      cmake \
      cppcheck \
      curl \
      g++ \
      gcc \
      git \
      lcov \
      ruby \
      sudo \
      wget \
      zip \
      zlib1g-dev \
      && \
    rm -rf /var/lib/apt/lists/*

RUN \
  mkdir -p /tmp/llvm-src && \
  cd /tmp/llvm-src && \
  wget https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-${LLVM_VERSION}.tar.gz && \
  tar zxf llvmorg-${LLVM_VERSION}.tar.gz

RUN mkdir /tmp/llvm-build
WORKDIR /tmp/llvm-build/

RUN \
  mkdir -p default && \
  cd default && \
  cmake \
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lldb;lld" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/llvm/default \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
     /tmp/llvm-src/llvm-project-llvmorg-${LLVM_VERSION}/llvm && \
  cmake --build . --target install -j16

RUN \
  mkdir -p msan && \
  cd msan && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/llvm/msan \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" \
    -DLIBCXX_INSTALL_EXPERIMENTAL_LIBRARY=NO \
    -DLLVM_USE_SANITIZER=MemoryWithOrigins \
     /tmp/llvm-src/llvm-project-llvmorg-${LLVM_VERSION}/runtimes && \
  cmake --build . --target install

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LLVM_VERSION=14.0.6

RUN apt-get update -qqy && \
    apt-get install -qqy \
      bzip2 \
      cmake \
      cppcheck \
      curl \
      g++ \
      gcc \
      git \
      ruby \
      wget \
      zip \
      zlib1g-dev

RUN apt-get install -qqy gcovr

COPY --from=0 /opt/llvm /opt/llvm

RUN \
  useradd -m builder && \
  echo "builder:builder" | chpasswd

# This is needed for GitLab CI
# See https://gitlab.com/gitlab-org/gitlab-runner/-/issues/1170
RUN \
  echo "dash dash/sh boolean false" | debconf-set-selections && \
  dpkg-reconfigure dash

USER builder

ENTRYPOINT [ "/bin/bash", "-c" ]
