ARG  BASE_IMAGE=ubuntu:18.04
FROM ${BASE_IMAGE}

ARG NGINX_VER
ARG INSTALL_TYPE
ARG SSL
ARG DEBIAN_FRONTEND=noninteractive

COPY . .

RUN bash -x .github/workflows/docker/wrapper.sh

RUN nginx -V

RUN nginx -t
