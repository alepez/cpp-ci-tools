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
      zip \
      && \
    rm -rf /var/lib/apt/lists/*

# https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads
RUN \
  cd /opt && \
  curl https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 | tar jxf -

RUN \
  useradd -m builder && \
  echo "builder:builder" | chpasswd && \
  adduser builder sudo && \
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# This is needed for GitLab CI
# See https://gitlab.com/gitlab-org/gitlab-runner/-/issues/1170
RUN \
  echo "dash dash/sh boolean false" | debconf-set-selections && \
  dpkg-reconfigure dash

USER builder

ENTRYPOINT [ "/bin/bash", "-c" ]
