FROM supersandro2000/base-alpine:edge

ENV USER factorio

RUN addgroup -S "$USER" && adduser -S -G "$USER" -u 1000 "$USER" \
  && addgroup "$USER" tty

COPY [ "files/entrypoint.sh", "/usr/local/bin/" ]

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=SC2016
RUN apk add --no-cache --no-progress ruby ruby-bigdecimal ruby-json ruby-nokogiri \
  && gem install bundler -v '~> 2' \
  && echo '*/15 * * * * ruby /app/factorio_mods_bot.rb -c "$CHANNEL" -t "$BOT_TOKEN" && $AFTER_COMMAND' | crontab -u "$USER" -

COPY [ "Gemfile", "Gemfile.lock", "/app/" ]

ENV BUNDLE_SILENCE_ROOT_WARNING=1
RUN bundle config set no-cache 'true' \
  && bundle install --with=alpine --gemfile=/app/Gemfile

COPY [ "factorio_mods_bot.rb", "/app/" ]

WORKDIR /app
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "crond", "-f", "-L", "/dev/stdout" ]
