FROM ruby:alpine

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

WORKDIR /usr/src/app/

RUN bundle install

WORKDIR /usr/src/restclient
