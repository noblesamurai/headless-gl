#!/bin/sh

# Make sure we are running from the top headless-gl path.
pushd $(dirname "$0")
pushd ..

# Build the docker image.
docker build -t gl-test -f swiftshader/Dockerfile .

# Check things have been linked properly.
docker run -it --rm gl-test ldd build/Release/webgl.node

# Run tests.
docker run -it --rm gl-test npm test
