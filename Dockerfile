ARG GOMINVERSION
FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:${GOMINVERSION}-alpine as builder

ARG VERSION

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN printf "I am running on ${BUILDPLATFORM:-linux/amd64}, building for ${TARGETPLATFORM:-linux/amd64}\n$(uname -a)\n" \
    && apk --update --no-cache add \
        build-base \
        git \
    && rm -rf /tmp/* /var/cache/apk/* \
    && git -c advice.detachedHead=false clone --branch ${VERSION} https://github.com/slackhq/nebula /go/src/github.com/slackhq/nebula \
    && cd /go/src/github.com/slackhq/nebula \
    && make BUILD_NUMBER="${VERSION#v}" build/$(echo ${TARGETPLATFORM:-linux/amd64} | sed -e "s/\/v/-/g" -e "s/\//-/g")/nebula \
    && make BUILD_NUMBER="${VERSION#v}" build/$(echo ${TARGETPLATFORM:-linux/amd64} | sed -e "s/\/v/-/g" -e "s/\//-/g")/nebula-cert \
    && mkdir -p /go/build/${TARGETPLATFORM:-linux/amd64} \
    && mv /go/src/github.com/slackhq/nebula/build/$(echo ${TARGETPLATFORM:-linux/amd64} | sed -e "s/\/v/-/g" -e "s/\//-/g")/nebula /go/build/${TARGETPLATFORM:-linux/amd64}/ \
    && mv /go/src/github.com/slackhq/nebula/build/$(echo ${TARGETPLATFORM:-linux/amd64} | sed -e "s/\/v/-/g" -e "s/\//-/g")/nebula-cert /go/build/${TARGETPLATFORM:-linux/amd64}/

FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:latest

ARG BUILD_DATE
ARG VERSION
ARG TARGETPLATFORM

LABEL maintainer="Martin Rubli" \
      org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.url="https://github.com/mrubli/nebula-container" \
      org.opencontainers.image.source="https://github.com/mrubli/nebula-container" \
      org.opencontainers.image.version=$VERSION \
      org.opencontainers.image.title="nebula" \
      org.opencontainers.image.description="Nebula is a scalable overlay networking tool with a focus on performance, simplicity and security from Slack" \
      org.opencontainers.image.licenses="MIT"

COPY --from=builder /go/build/${TARGETPLATFORM:-linux/amd64}/nebula /usr/local/bin/nebula
COPY --from=builder /go/build/${TARGETPLATFORM:-linux/amd64}/nebula-cert /usr/local/bin/nebula-cert
#RUN nebula -version
#RUN nebula-cert -version

VOLUME ["/config"]

COPY nebula-wrapper.sh /usr/local/bin/

ENTRYPOINT [ "/usr/local/bin/nebula-wrapper.sh" ]
CMD ["-config", "/config/config.yaml"]
