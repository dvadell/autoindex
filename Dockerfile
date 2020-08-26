FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt update && \
    apt install -y perl-modules-5.30 libapache2-mod-perl2 apache2 libdata-dumper-simple-perl \
                   libjson-perl libtemplate-perl

RUN apt install -y cpanminus make

RUN cpanm MIME::Type::FileName

CMD /usr/sbin/apachectl -DFOREGROUND

