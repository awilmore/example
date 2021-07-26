#!/bin/bash

set -e

echo
echo " * Compiling amd64 image ..."
echo

docker buildx build . \
  --tag example:latest \
  --file Dockerfile \
  --platform linux/amd64 \
  --load

echo
echo " * Done."
echo

