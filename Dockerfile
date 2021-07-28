FROM ubuntu:21.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

RUN apt-get update -qqy && \
    apt-get install -qqy cmake \
                         clang \
                         clang-format \
                         clang-tidy \
                         cppcheck \
                         curl \
                         g++ \
                         gcc \
                         git \
                         lcov \
                         && \
    rm -rf /var/lib/apt/lists/*

# https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads
RUN cd /opt && curl https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2 | tar jxf -

RUN useradd -m builder
USER builder

CMD ["bash"]
