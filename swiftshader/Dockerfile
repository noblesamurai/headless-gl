FROM launcher.gcr.io/google/clang-debian9 AS build

ARG DIR="/tmp/headless-gl"

RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y \
    build-essential \
    curl \
    g++ \
    gcc \
    git \
    libxi-dev \
    make \
    pkg-config \
    python

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash
RUN apt-get install -y nodejs

RUN mkdir -p ${DIR}
WORKDIR ${DIR}

ADD https://storage.googleapis.com/skia-swiftshader/libGLESv2.so ${DIR}/lib/libGLESv2.so
ADD https://storage.googleapis.com/skia-swiftshader/libEGL.so ${DIR}/lib/libEGL.so
RUN git clone --depth 1 --shallow-submodules https://swiftshader.googlesource.com/SwiftShader /tmp/swiftshader

COPY . ${DIR}/
RUN npm install

ENV PKG_CONFIG_PATH=${DIR}/swiftshader
ENV LDFLAGS='-Wl,-rpath,./lib'
RUN npm_config_headless_gl_pkg_config=pkg-config npm run rebuild
