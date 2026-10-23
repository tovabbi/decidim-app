FROM ruby:3.4-bookworm

ARG NODE_VERSION=22.14.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev imagemagick libvips-dev git curl xz-utils ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Pin the exact Node version, using the right binary for x64 or arm64
RUN ARCH="$(dpkg --print-architecture | sed 's/amd64/x64/')" \
 && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" \
    | tar -xJ -C /usr/local --strip-components=1 --no-same-owner \
 && node --version && npm --version

WORKDIR /app
ENV RAILS_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN npm install

# Dummy values only so assets can compile; they are not kept in the image
RUN SECRET_KEY_BASE=dummy DATABASE_URL=postgres://u:p@localhost/db \
    bundle exec rails shakapacker:compile

EXPOSE 3000
CMD ["sh", "-c", "if [ \"$PROCESS_TYPE\" = \"sidekiq\" ]; then exec bundle exec sidekiq -C config/sidekiq.yml; else exec bundle exec puma -C config/puma.rb; fi"]
