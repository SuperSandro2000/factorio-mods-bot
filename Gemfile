# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'httparty', '>= 0.17.3'
gem 'nokogiri', '>= 1.10.7'

# on alpine we need to check if some stdlib gems are installed
group :alpine do
  gem "bigdecimal", "1.4.1"
  gem "json", "2.1.0"
end
