ARG PHP_VERSION=8.5
ARG DISTRO=bookworm

FROM dunglas/frankenphp:php${PHP_VERSION}-${DISTRO} AS builder
ARG PHP_VERSION

RUN apt-get update && apt-get install -y \
    libgeos-dev \
    git \
    autoconf \
    build-essential \
    --no-install-recommends

WORKDIR /tmp/php-geos-src
COPY . .

RUN make clean || true && \
    ./autogen.sh && \
    ./configure --with-php-config=/usr/local/bin/php-config && \
    make -j$(nproc) && \
    make install
    
FROM php:${PHP_VERSION}-fpm-${DISTRO}

RUN apt-get update && apt-get install -y \
    libgeos-c1v5 \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
RUN docker-php-ext-enable geos

RUN php -m | grep geos