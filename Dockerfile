FROM ruby:alpine
MAINTAINER zdp@thoomtech.com

COPY ["Gemfile", "Gemfile.lock", "/usr/src/app/"]

RUN cd /usr/src/app/ && bundle install

WORKDIR /usr/src/restclient
ENTRYPOINT ["restclient"]
