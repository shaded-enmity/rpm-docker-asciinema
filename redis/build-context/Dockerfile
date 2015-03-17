FROM fedora:21
MAINTAINER Pavel Odvody <podvody@redhat.com>

RUN yum update -y \
 && yum install -y redis \
 && yum clean -y all

ADD start.sh /

EXPOSE 6379
VOLUME /var/lib/redis

CMD ["/start.sh"]
