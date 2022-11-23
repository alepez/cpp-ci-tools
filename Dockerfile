FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LLVM_VERSION=14.0.6

RUN apt-get update -qqy && \
    apt-get install -qqy \
      build-essential \
      bzip2 \
      clang \
      clang-format \
      clang-tidy \
      cmake \
      cppcheck \
      curl \
      g++ \
      gcc \
      gcc-multilib \
      git \
      lcov \
      python3-distutils \
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
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_C_COMPILER=clang \
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld;lldb;" \
    -DLLVM_ENABLE_RUNTIMES="all" \
     /tmp/llvm-src/llvm-project-llvmorg-${LLVM_VERSION}/llvm && \
  cmake --build . --target install

RUN \
  mkdir -p msan && \
  cd msan && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_INSTALL_PREFIX=/opt/llvm/msan \
    -DLIBCXX_INSTALL_EXPERIMENTAL_LIBRARY=NO \
    -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi" \
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
      gcovr \
      git \
      libstdc++-11-dev \
      ruby \
      wget \
      zip \
      zlib1g-dev \
      && \
    rm -rf /var/lib/apt/lists/*

COPY --from=0 /opt/llvm /opt/llvm
COPY --from=0 /usr/local /usr/local

RUN \
  useradd -m builder && \
  echo "builder:builder" | chpasswd

# This is needed for GitLab CI
# See https://gitlab.com/gitlab-org/gitlab-runner/-/issues/1170
RUN \
  echo "dash dash/sh boolean false" | debconf-set-selections && \
  dpkg-reconfigure dash

USER builder

ENV LLVM_MSAN=/opt/llvm/msan

# This is needed for GitLab CI
ENTRYPOINT [ "/bin/bash", "-c" ]
