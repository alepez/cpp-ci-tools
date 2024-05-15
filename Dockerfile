FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV LLVM_VERSION=14.0.6

RUN apt-get update -qqy && \
    apt-get install -qqy \
      bzip2 \
      cmake \
      clang \
      cppcheck \
      curl \
      gcovr \
      git \
      libstdc++-11-dev \
      ruby \
      wget \
      zip \
      zlib1g-dev \
      clang-format \
      clang-tidy \
      build-essential \
      valgrind

RUN \
  useradd -m builder && \
  echo "builder:builder" | chpasswd

USER builder
