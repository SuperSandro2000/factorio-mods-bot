FROM supersandro2000/base-alpine:3.13

ENV USER factorio

RUN addgroup -S "$USER" && adduser -S -G "$USER" -u 1000 "$USER" \
  && addgroup "$USER" tty

COPY [ "files/entrypoint.sh", "/usr/local/bin/" ]

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# bust cache when updating Gemfile to fetch newer prebuild gems
COPY [ "Gemfile", "Gemfile.lock", "/app/" ]

ENV BUNDLE_SILENCE_ROOT_WARNING=1
# hadolint ignore=SC2016
RUN apk add --no-cache --no-progress \
    libxslt \
    ruby \
    ruby-bundler \
  && apk add --no-cache --no-progress --virtual .build-deps \
    gcc \
    libxslt-dev \
    make \
    musl-dev \
    pkgconf \
    ruby-dev \
    zlib-dev \
  && bundle config set no-cache 'true' \
  && bundle config build.nokogiri --use-system-libraries \
  && bundle install --gemfile=/app/Gemfile \
  && apk del --no-cache .build-deps \
\
  && echo '*/15 * * * * $BEFORE_COMMAND ; ruby /app/factorio_mods_bot.rb -c "$CHANNEL" -t "$BOT_TOKEN" && $AFTER_COMMAND' | crontab -u "$USER" -

COPY [ "factorio_mods_bot.rb", "/app/" ]

WORKDIR /app
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "crond", "-f", "-L", "/dev/stdout" ]
