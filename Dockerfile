FROM ruby:2.1
MAINTAINER Secret Sauce Partners, Inc. <dev@sspinc.io>

RUN mkdir -p /opt/csv2avro
WORKDIR /opt/csv2avro

COPY pkg/*.gem /opt/csv2avro/csv2avro.gem

RUN gem install csv2avro.gem

ENTRYPOINT ["csv2avro"]
