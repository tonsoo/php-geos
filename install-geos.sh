#!/usr/bin/env sh
set -eux

GEOS_VERSION="${GEOS_VERSION:-v1.0.0}"
PHP_VERSION="$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')"

if [ -f /etc/alpine-release ]; then
  DISTRO="alpine"
elif [ -f /etc/debian_version ]; then
  DISTRO="${DISTRO:-bookworm}"
else
  echo "Unsupported distro"
  exit 1
fi

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
esac

TARBALL="geos-${PHP_VERSION}-linux-${DISTRO}-${ARCH}.tar.gz"
URL="https://github.com/ghsgabriel/php-geos/releases/download/${GEOS_VERSION}/${TARBALL}"

echo "Downloading $URL"
curl -fL -o /tmp/geos.tar.gz "$URL"

tar -xzf /tmp/geos.tar.gz -C /

if command -v ldconfig >/dev/null 2>&1; then
  ldconfig
fi

echo "extension=geos.so" > /usr/local/etc/php/conf.d/geos.ini

php -r "if(!class_exists('GEOSGeometry')) { echo 'GEOS NOT FOUND'; exit(1); }"

rm -f /tmp/geos.tar.gz

echo "GEOS installed successfully"
