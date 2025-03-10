FROM alpine:3.13 AS base

ARG LUA_VERSION=5.1

RUN apk add --no-cache lua${LUA_VERSION} lua${LUA_VERSION}-dev build-base git bash unzip curl openssl-dev && \
    ln -s /usr/bin/lua${LUA_VERSION} /usr/local/bin/lua && \
    cd /tmp && \
    git clone https://github.com/keplerproject/luarocks.git && \
    cd luarocks && \
    sh ./configure --lua-version=${LUA_VERSION} && \
    make build install && \
    rm -rf /tmp/*

FROM base AS build

# the wget that comes packaged with alpine doesn't support the flags luarocks passes to it to get the manifest file for luarocks that correspond to a particular version of lua on the system. We have to install wget that is not the busybox implementation that ships default with alpine linux
RUN apk add wget

# yaml-dev is the C lib files that the libyaml luarock depends on
RUN apk add yaml-dev 

# install the most recent version of lyaml for lua 5.1
RUN luarocks install lyaml 6.2.8-1

# install base64 dependency for kube.nvim
RUN luarocks install base64 1.5-3


COPY lua /data/lua

COPY kube-scm-1.rockspec /data/

RUN cd /data && luarocks make
