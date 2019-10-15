FROM supersandro2000/base-alpine:edge

ENV USER factorio

RUN addgroup -S "$USER" && adduser -S -G "$USER" -u 1000 "$USER" \
  && addgroup "$USER" tty

COPY [ "files/entrypoint.sh", "/usr/local/bin/" ]
COPY [ "files/cron", "/app/" ]

RUN apk add --no-cache --no-progress ruby ruby-bigdecimal ruby-json ruby-nokogiri ruby-rdoc \
  && gem install bundler -v '~> 2' \
  && crontab -u "$USER" /app/cron

COPY [ "Gemfile", "Gemfile.lock", "/app/" ]

ENV BUNDLE_SILENCE_ROOT_WARNING=1
RUN bundle install --no-cache --with=alpine --gemfile=/app/Gemfile

COPY [ "factorio_mods_bot.rb", "/app/" ]

WORKDIR /app
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "crond", "-f", "-L", "/dev/stdout" ]
