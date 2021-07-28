FROM ubuntu:21.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

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
      sudo \
      && \
    rm -rf /var/lib/apt/lists/*

# https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads
RUN \
  cd /opt && \
  curl https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2 | tar jxf -

RUN \
  useradd -m builder && \
  echo "builder:builder" | chpasswd && \
  adduser builder sudo && \
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER builder

ENTRYPOINT [ "/bin/bash", "-c" ]
