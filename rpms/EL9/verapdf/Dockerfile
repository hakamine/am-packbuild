FROM rockylinux:9
MAINTAINER Jörg Sachse <Joerg.Sachse@slub-dresden.de>

### install build tools
RUN yum update -y

RUN yum install -y rpmdevtools gpg* rng-tools \
                   make wget java-1.8.0-openjdk.x86_64
RUN yum clean all && rm -rf /var/cache/yum
