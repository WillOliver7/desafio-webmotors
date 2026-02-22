# syntax = docker/dockerfile:1
ARG RUBY_VERSION=3.1.4
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle" \
    PATH="/usr/local/bundle/bin:${PATH}"

# 2. ESTÁGIO DE BUILD
FROM base as build
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential git libpq-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install

# 3. ESTÁGIO FINAL
FROM base
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY . .

# NENHUM comando de 'playwright install' aqui. 
# O container do Playwright já tem tudo o que precisamos.

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]