FROM golang:1.16.5-alpine3.14

# Copy source code into container
ARG BUILD_PATH=/src/github.com/awilmore/example

WORKDIR /src
COPY . $BUILD_PATH

# Compile source code
RUN cd $BUILD_PATH/gotypes && \
    CGO_ENABLED=0 go build -ldflags="-w" -tags=timetzdata ./...
