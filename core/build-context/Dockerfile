FROM fedora:21
MAINTAINER Pavel Odvody <podvody@redhat.com>

RUN yum update -y
RUN yum install -y bzip2 libxml2{,-devel} libxslt{,-devel} \
                   libtool ruby{,-devel} make autoconf postgresql \
                   libpqxx{,-devel} git gcc-c++ nodejs bzip2 \
 && yum clean -y all

ENV RAILS_ENV=production

RUN gem install bundler
RUN gem install sidekiq

RUN git clone http://cgit.freedesktop.org/~dvdhrm/libtsm/
WORKDIR /libtsm

RUN git checkout bb4e4543dbd9ffbc18e1ac7e803780b4401d55f0
RUN ./autogen.sh \
 && ./configure --prefix=/usr/local \
 && make \
 && make install \
 && ldconfig

RUN cp /usr/local/lib/libtsm.so.1 /usr/lib64/ \
 && ldconfig

WORKDIR /

RUN git clone https://github.com/asciinema/asciinema.org
WORKDIR /asciinema.org

ADD database.yml /asciinema.org/config/
WORKDIR src/
RUN make

WORKDIR /asciinema.org
RUN rm -f log/* \
 && bundle install

WORKDIR /

ADD start.sh /
ADD production.rb /asciinema.org/config/environments/production.rb

WORKDIR /asciinema.org
RUN bundle exec rake assets:precompile
WORKDIR /

VOLUME /asciinema.org/public/uploads

EXPOSE 3000

CMD /start.sh
