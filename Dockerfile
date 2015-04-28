FROM ruby:2.1
MAINTAINER Secret Sauce Partners, Inc. <dev@sspinc.io>

RUN mkdir -p /opt/csv2avro
WORKDIR /opt/csv2avro

COPY pkg/csv2avro-latest.gem /opt/csv2avro/csv2avro-latest.gem

RUN gem install csv2avro-latest.gem

ENTRYPOINT ["csv2avro"]
