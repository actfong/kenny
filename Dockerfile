FROM ruby:2.3.4-alpine

RUN apk update && \
    apk add build-base

ENV APP_PATH /app

WORKDIR $APP_PATH

COPY Gemfile* $APP_PATH/
COPY kenny.gemspec $APP_PATH/

ENV \
  BUNDLE_GEMFILE=$APP_PATH/Gemfile \
  BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

RUN bundle install

ADD . $APP_PATH
