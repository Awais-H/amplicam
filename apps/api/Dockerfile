FROM ruby:3.3.0-slim

ENV RAILS_ENV=production \
    RACK_ENV=production

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential libpq-dev libvips-dev git postgresql-client && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile ./
RUN bundle install

COPY . .

EXPOSE 3000

CMD ["bash", "bin/start-production"]
