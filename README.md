# Factorio-Mods-Bot

Factorio mod portal notification bot for Telegram.
Currently in Alpha testing.

PR's are welcome as long as they are reasonable and formatted with ``rubocop``.

# Usage

* To install all required gems run `bundle install` inside the repository.
* To run the bot provide a chat_id and bot token like `ruby factorio_mods_bot --chat '@chat' --token 'bot12345:ABCDEFG'`.
* When running the first time it is adviced to add the `--setup` flag or the bot parses all pages and send a notification for each mod. With the flag it only send a notification for the last updated mod and starts from there the next time.
