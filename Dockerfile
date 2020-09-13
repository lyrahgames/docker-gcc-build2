# ARG UBUNTU_BUILDER_VERSION=latest
ARG GCC_BUILDER_VERSION=latest
# ARG GCC_VERSION=latest
ARG UBUNTU_VERSION=latest

# Build Stage
FROM gcc:${GCC_BUILDER_VERSION} AS builder
# FROM ubuntu:${UBUNTU_BUILDER_VERSION} AS builder
# # Get build2 compilation requirements.
# RUN \
#   apt-get update && \
#   apt-get install -y \
#     gcc \
#     g++ \
#     make \
#     curl \
#     wget \
#     openssl \
#   && \
#   rm -rf /var/lib/apt/lists/*

# Pull build2 sources, compile, and install them.
ARG BUILD2_VERSION=0.13.0
RUN \
  curl -sSfO https://download.build2.org/$BUILD2_VERSION/build2-install-$BUILD2_VERSION.sh && \
  sh build2-install-$BUILD2_VERSION.sh --yes --sudo false --no-check --trust yes /opt/build2

# Deployment Stage
# The official GCC image 'gcc' is too large.
# An Ubuntu image in production reduces the image size by a factor of six.
# FROM gcc:$GCC_VERSION AS deployer
FROM ubuntu:${UBUNTU_VERSION} AS deployer

ARG GCC_VERSION=9
RUN \
  echo "GCC_VERSION=$GCC_VERSION" && \
  apt-get update && \
  apt-get install -y \
    gcc-$GCC_VERSION \
    g++-$GCC_VERSION \
    curl \
    wget \
    openssl \
    git \
  && \
  # apt-get autoremove && \
  rm -rf /var/lib/apt/lists/* && \
  # update-alternatives --remove-all gcc && \
  # update-alternatives --remove-all g++ && \
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-$GCC_VERSION 10 && \
  update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 20 && \
  update-alternatives --set cc /usr/bin/gcc && \
  update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-$GCC_VERSION 10 && \
  update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 20 && \
  update-alternatives --set c++ /usr/bin/g++

COPY --from=builder /opt/build2 /opt/build2
ENV PATH "/opt/build2/bin:$PATH"
LABEL maintainer="lyrahgames@mailbox.org"