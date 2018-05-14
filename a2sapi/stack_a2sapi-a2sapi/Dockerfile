# I don't care about image size in builder since it's... well, just the builder
# More layers for more caching
FROM golang:1.10-alpine as builder0

RUN apk add --no-cache --virtual .build-deps \
      git

ARG a2sapi_PATH=/go/src/github.com/syncore/a2sapi
ARG a2sapi_VERSION=0.1.8
LABEL a2sapi_VERSION=${a2sapi_VERSION}

# get project
RUN mkdir -p ${a2sapi_PATH} \
    && cd    ${a2sapi_PATH} \
    && git clone --branch ${a2sapi_VERSION} https://github.com/syncore/a2sapi.git .

RUN apk add --no-cache --virtual .project-deps \
      gcc \
      libc-dev

# build app and test
RUN cd ${a2sapi_PATH}/build/nix \
    && ./build.sh \
    && ./run_tests.sh

# getfiles
RUN cd ${a2sapi_PATH}/getfiles \
    && ./get_countrydb.sh

# app is now compiled and ready to be copied
# /go/src/github.com/syncore/a2sapi/bin/

# now I care about image size
FROM golang:1.10-alpine

# add app
COPY --from=builder0 /go/src/github.com/syncore/a2sapi/bin/ /a2sapi/
COPY ./.docker/a2sapi/conf/*.conf /a2sapi/conf/

# add log to container output
RUN mkdir -p /a2sapi/logs/ \
    && ln -sf /dev/stdout /a2sapi/logs/app.log

WORKDIR /a2sapi

CMD ["/a2sapi/a2sapi"]