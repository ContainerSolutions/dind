FROM ubuntu:14.04
MAINTAINER jerome.petazzoni@docker.com

# Let's start with some basic stuff.
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    software-properties-common
    
# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ubuntu/ | sh

# Define additional metadata for our image.
VOLUME /var/lib/docker

# install logspout (based on https://github.com/gliderlabs/logspout/blob/master/Dockerfile.dev)
RUN add-apt-repository ppa:evarlast/golang1.4 && apt-get update -qq
ENV GOPATH /go
RUN apt-get install -qqy golang mercurial && git clone https://github.com/gliderlabs/logspout.git /go/src/github.com/gliderlabs/logspout/ && \
    cd /go/src/github.com/gliderlabs/logspout/ && go get && go build -ldflags "-X main.Version $(cat VERSION)" -o /bin/logspout && \
    rm -fr /go && apt-get purge -qqy golang mercurial
VOLUME /mnt/routes

# Install the magic wrapper.
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Install the entrypoint script
ADD ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh

