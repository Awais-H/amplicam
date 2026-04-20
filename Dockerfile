FROM ruby:3.3.0-slim

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential libpq-dev libvips-dev git postgresql-client && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app/apps/api

COPY apps/api/Gemfile ./
COPY apps/api/Gemfile.lock ./
RUN bundle install

COPY apps/api ./

EXPOSE 3000

CMD ["bash", "-lc", "bundle exec rake db:migrate && bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}"]
