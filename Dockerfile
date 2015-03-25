FROM ruby:2.1

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile* *.gemspec /usr/src/app/
COPY lib/csv2avro/version.rb /usr/src/app/lib/csv2avro/version.rb
RUN bundle install

COPY . /usr/src/app
