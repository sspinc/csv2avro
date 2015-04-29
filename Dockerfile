FROM ruby:2.1
MAINTAINER Secret Sauce Partners, Inc. <dev@sspinc.io>

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /srv/csv2avro
WORKDIR /srv/csv2avro

COPY . /srv/csv2avro/

RUN bundle install

ENTRYPOINT ["csv2avro"]
