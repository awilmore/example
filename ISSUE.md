# CROSS-COMPILE SEGFAULT ISSUE


### Setup

Install docker and buildx on standard Amazon Linux instance running on graviton:

```
# Install git
sudo yum install -y git

# Install docker
sudo amazon-linux-extras install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install buildx
mkdir -p /home/ec2-user/.docker/cli-plugins
curl -L --output /home/ec2-user/.docker/cli-plugins/docker-buildx https://github.com/docker/buildx/releases/download/v0.6.0/buildx-v0.6.0.linux-arm64
chmod +x ~/.docker/cli-plugins/docker-buildx

# Install binfmt
docker run --privileged --userns=host --rm tonistiigi/binfmt --install amd64
```


### Clone example project

```
# Create workspace
export WORKSPACE=$HOME/work
mkdir -p $WORKSPACE

# Clone example.git to local workspace
cd $WORKSPACE
git clone https://github.com/awilmore/example.git

# Check out test branch
cd $WORKSPACE/example
git checkout dev-segfault-example-1
```


### Run build

```
cd $WORKSPACE/example
./cross-build.sh
```


### Example output:

Please Note: this issue appears to be intermittent, so please rerun (using `docker buildx prune` each time before running a new build).

```
# Prune buidx cache
[ec2-user@ip-172-31-30-195 example]$ docker buildx prune -f
ID                                    RECLAIMABLE    SIZE    LAST ACCESSED
jm5vfzevn06iy9auwcnz6iq91*            true           0B
dr2cxdl49h1un7omqacd3ycgd*            true           369.67kB
25k0icaltuqfhtha0uyvqrkw6*            true           265B
...

# Run build script
[ec2-user@ip-172-31-30-195 ~]$ cd $WORKSPACE/example
[ec2-user@ip-172-31-30-195 example]$ ./cross-build.sh

 * Compiling amd64 image ...

[+] Building 20.4s (8/8) FINISHED
 => [internal] load build definition from Dockerfile                                              0.0s
 => => transferring dockerfile: 304B                                                              0.0s
 => [internal] load .dockerignore                                                                 0.0s
 => => transferring context: 2B                                                                   0.0s
 => [internal] load metadata for docker.io/library/golang:1.16.5-alpine3.14                       1.6s
 => [1/4] FROM docker.io/library/golang:1.16.5-alpine3.14@sha256:3361eb3ffa949cf0cf60c1377869718  6.8s
 => => resolve docker.io/library/golang:1.16.5-alpine3.14@sha256:3361eb3ffa949cf0cf60c1377869718  0.0s
 => => sha256:f9f518c7ffbf45f5b30441802813beb30e046d641addc5bf108147f9fc2cadb2 1.36kB / 1.36kB    0.0s
 => => sha256:2592d553708ff6173730510bf673f60180b2c07d86cb6844a70e96c8b2493b25 4.87kB / 4.87kB    0.0s
 => => sha256:5843afab387455b37944e709ee8c78d7520df80f8d01cf7f861aae63beeddb6b 2.81MB / 2.81MB    0.4s
 => => sha256:3d8dd7cab73593e079aa6f5b2fe6c2adfe09761320c162696f8fbdc9d81c99 281.50kB / 281.50kB  0.7s
 => => sha256:4cac70760d29a8ed86a3f007ed2410ef62cc877ddd2ceaa3e10806664fb3d1d1 155B / 155B        0.5s
 => => sha256:3361eb3ffa949cf0cf60c13778697183a22684e0a0a5edf9ccb9d2f1ae4da873 1.22kB / 1.22kB    0.0s
 => => extracting sha256:5843afab387455b37944e709ee8c78d7520df80f8d01cf7f861aae63beeddb6b         0.1s
 => => sha256:b5538a40838209da51f46c4f6d25d4d145cde85763eb2d3f09c1b57a4745d8 105.82MB / 105.82MB  3.3s
 => => sha256:b652665b27e70a674e7e132e56a85f0907653b50ca0f567c029d3f303a604120 154B / 154B        0.9s
 => => extracting sha256:3d8dd7cab73593e079aa6f5b2fe6c2adfe09761320c162696f8fbdc9d81c99e6         0.1s
 => => extracting sha256:4cac70760d29a8ed86a3f007ed2410ef62cc877ddd2ceaa3e10806664fb3d1d1         0.0s
 => => extracting sha256:b5538a40838209da51f46c4f6d25d4d145cde85763eb2d3f09c1b57a4745d80f         3.0s
 => => extracting sha256:b652665b27e70a674e7e132e56a85f0907653b50ca0f567c029d3f303a604120         0.0s
 => [internal] load build context                                                                 0.0s
 => => transferring context: 374.46kB                                                             0.0s
 => [2/4] WORKDIR /src                                                                            0.4s
 => [3/4] COPY . /src/github.com/awilmore/example                                                 0.1s
 => ERROR [4/4] RUN cd /src/github.com/awilmore/example/gotypes &&     CGO_ENABLED=0 go build -  11.3s
------
 > [4/4] RUN cd /src/github.com/awilmore/example/gotypes &&     CGO_ENABLED=0 go build -ldflags="-w" -tags=timetzdata ./...:
#8 2.527 go: downloading golang.org/x/tools v0.0.0-20210112183307-1e6ecd4bf1b0
#8 9.894 go tool compile: signal: segmentation fault (core dumped)
------
error: failed to solve: executor failed running [/bin/sh -c cd $BUILD_PATH/gotypes &&     CGO_ENABLED=0 go build -ldflags="-w" -tags=timetzdata ./...]: exit code: 1

```

