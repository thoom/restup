FROM ruby:alpine
MAINTAINER Z.d. Peacock <zdp@thoomtech.com>

COPY ["Gemfile", "Gemfile.lock", "/src/"]

RUN cd /src && bundle install

WORKDIR /restclient
ENTRYPOINT ["restclient"]
