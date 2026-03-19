ARG RUBY_VERSION=3.4.7

########################
# Base de build
########################
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /tattoo

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libyaml-dev \
      libjemalloc2 \
      libvips \
      libpq-dev \
      imagemagick \
      ghostscript \
      ca-certificates \
      build-essential \
    && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_JOBS=4 \
    BUNDLE_PATH=/bundle \
    GEM_HOME=/bundle \
    PATH="/bundle/bin:$PATH"

########################
# Etapa de dependências (cache forte aqui)
########################
FROM base AS bundle

COPY Gemfile Gemfile.lock ./
RUN bundle install

########################
# Imagem final (runtime)
########################
FROM base

WORKDIR /tattoo

# Reaproveita gems já instaladas
COPY --from=bundle /bundle /bundle

# Copia o app depois para não invalidar o cache do bundle à toa
COPY . .

EXPOSE 80

ENTRYPOINT ["./bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
