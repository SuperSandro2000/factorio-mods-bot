FROM supersandro2000/base-alpine

ENV USER factorio

RUN addgroup -S "$USER" && adduser -G "$USER" -S -u 1000 "$USER"

COPY [ "files/entrypoint.sh", "/usr/local/bin/" ]
COPY [ "files/cron", "/app/" ]

RUN apk add --no-cache --no-progress ruby ruby-bigdecimal ruby-json ruby-nokogiri \
  && gem install bundler -v '~> 2' \
  && addgroup "$USER" tty \
  && crontab -u "$USER" /app/cron

WORKDIR /app

COPY [ "Gemfile", "Gemfile.lock", "/app/" ]

RUN bundle install --no-cache --with=alpine

COPY [ "factorio_mods_bot.rb", "/app/" ]

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "crond", "-f", "-L", "/dev/stdout" ]
