FROM fedora:21
MAINTAINER Pavel Odvody <podvody@redhat.com>

ENV LANG en_US.utf8
RUN groupadd -r postgres && useradd -r -g postgres postgres

RUN yum update -y \
 && yum install -y postgresql{,-server,-devel,-libs} sudo \
 && yum clean -y all

ADD pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf 
ADD postgresql.conf /etc/postgresql/9.3/main/postgresql.conf 
ADD start.sh /

RUN chown postgres:postgres /etc/postgresql/9.3/main/*.conf

VOLUME ["/var/lib/postgresql"]
EXPOSE 5432

CMD ["/start.sh"]
