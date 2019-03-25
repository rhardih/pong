FROM ruby:2.6.1-alpine

ARG VERSION
ENV VERSION $VERSION

RUN apk add --update \
      build-base \
      nodejs \
      postgresql-dev \
      tzdata \
      git

RUN mkdir /pong
WORKDIR /pong

COPY Gemfile /pong/Gemfile
COPY Gemfile.lock /pong/Gemfile.lock

RUN bundle install
COPY . /pong

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
