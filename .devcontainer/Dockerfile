FROM ruby:3.2-alpine

RUN apk add --no-cache \
  build-base \
  git \
  bash \
  tzdata \
  nodejs \
  yarn \
  vim \
  curl \
  less \
  && rm -rf /var/cache/apk/*

WORKDIR /workspace
