FROM ruby:2.1
MAINTAINER Secret Sauce Partners, Inc. <dev@sspinc.io>

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python2.7 get-pip.py && \
    pip install awscli

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /srv/csv2avro
WORKDIR /srv/csv2avro

RUN mkdir -p /srv/csv2avro/lib/csv2avro

COPY lib/csv2avro/version.rb /srv/csv2avro/lib/csv2avro/version.rb
COPY csv2avro.gemspec Gemfile Gemfile.lock /srv/csv2avro/

RUN bundle install

COPY . /srv/csv2avro

ENTRYPOINT ["./bin/csv2avro"]
