FROM rockylinux:9

# Environmnet variables needed during build
ENV GOVERSION 1.21.4
ENV GOOS linux
ENV GOARCH amd64

# Environment variables needed during runtime
ENV GOPATH /go
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

RUN yum -y install rpm-build make git systemd-rpm-macros which npm && \
	curl -sO https://storage.googleapis.com/golang/go${GOVERSION}.${GOOS}-${GOARCH}.tar.gz && \
	tar -C /usr/local -xzf go${GOVERSION}.${GOOS}-${GOARCH}.tar.gz && \
	rm go${GOVERSION}.${GOOS}-${GOARCH}.tar.gz
