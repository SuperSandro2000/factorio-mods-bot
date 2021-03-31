# Factorio Mods Bot

![GitHub repo size in bytes](https://img.shields.io/github/repo-size/SuperSandro2000/factorio_mods_bot.svg?logo=github&label=Repo%20size&maxAge=3600)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2FSuperSandro2000%2Ffactorio_mods_bot.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2FSuperSandro2000%2Ffactorio_mods_bot?ref=badge_shield)

Factorio mod portal notification bot for Telegram.
Currently in Alpha testing.

PR's are welcome as long as they are reasonable and formatted with ``rubocop``.

# Usage

* To install all required gems run `bundle install` inside the repository.
* To run the bot provide a chat_id and bot token like `ruby factorio_mods_bot --chat '@chat' --token 'bot12345:ABCDEFG'`.
* When running the first time it is adviced to add the `--setup` flag or the bot parses all pages and send a notification for each mod. With the flag it only send a notification for the last updated mod and starts from there the next time.
