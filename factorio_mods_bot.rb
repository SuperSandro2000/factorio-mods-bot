#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright (C) 2019 Sandro Jäckel.  All rights reserved.
#
# This file is part of Factorio-Mods-Bot.
#
# Factorio-Mods-Bot is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Canuby is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this porgram. If not, see <http://www.gnu.org/licenses/>.
# require 'active_support/core_ext/hash/conversions'
require 'httparty'
require 'nokogiri'
require 'optparse'
require 'ostruct'
require 'yaml'

@options = OpenStruct.new
parser = OptionParser.new do |opts|
  opts.on('-c', '--chat [chat]', 'Telegram chat_id where to send the notifications') do |c|
    @options.chat = c
  end

  opts.on('-s', '--setup', 'Setup the yaml file.') do |_t|
    @options.setup = true
  end

  opts.on('-t', '--token [token]', 'Takes a telegram token to send notifications') do |t|
    @options.token = t
  end

  opts.on_tail('-h', '--help', 'Show this help message') do
    puts opts
    exit
  end
end

begin
  parser.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  puts('Unknown argument')
  puts(e)
end

if @options.token.nil?
  puts "Provide a bot token like: ruby factorio_mods_bot TOKEN='bot12345:ABCDEFG'"
  exit
end

@options.file = '/app/factorio-mods-data.yml'

# dummy Class
class Scraper
  def page(url)
    response = HTTParty.get(url)
    @page ||= Nokogiri::HTML(response.body)
  end
end

def mod_name(mod)
  @mods_page[mod]['href'].split('/mod/')[1]
end

def send_notification(name, author, link, to_version, new)
  text = if new
           "New Mod added: #{name} at version #{to_version} by #{author} - #{link}"
         else
           "Updated Mod: #{name} to version #{to_version} by #{author} - #{link}"
         end
  HTTParty.post("https://api.telegram.org/#{@options.token}/sendMessage", body: { 'chat_id' => @options.chat, 'text' => text })
  # p text
end

if File.exist?(@options.file) && !@options.setup
  @mods = YAML.load_file(@options.file)
else
  @options.setup = true
  @mods = {}
end

@new_mods_pages = Scraper.new.page('https://mods.factorio.com/?version=any').css('.active-filters-bar').css('.pagination').css('li')[4].text.split(' ')[0].to_i

(1...@new_mods_pages).each do |page|
  @mods_page = Scraper.new.page("https://mods.factorio.com/#{page}").css('.mod-card').css('.mod-card-info-container').css('.mod-card-title').css('a')

  (0...@mods_page.size).each do |mod|
    @mods[mod_name(mod)] = {} unless @mods.key?(mod_name(mod))
    @mods[mod_name(mod)].merge!('name' => @mods_page[mod].text, 'link' => @mods_page[mod]['href'])
  end

  (0...@mods_page.size).each do |mod|
    link = "https://mods.factorio.com#{@mods[mod_name(mod)]['link']}"
    mod_page = Scraper.new.page(link).css('.mod-page-data-table')
    author = mod_page.css('td')[1].text
    online_version = mod_page.css('td')[11].text.split(' (')[0]

    if @mods[mod_name(mod)]['version'] == online_version
      # processed all updated/new mods
      @options.done = true
      break
    elsif @mods[mod_name(mod)]['version'].nil?
      send_notification(@mods[mod_name(mod)]['name'], author, link, online_version, true)
      @mods[mod_name(mod)]['version'] = online_version
    else
      send_notification(@mods[mod_name(mod)]['name'], author, link, online_version, false)
      @mods[mod_name(mod)]['version'] = online_version
    end

    break if @options.setup
  end

  break if @options.setup || @options.done

  File.write(@options.file, @mods.to_yaml)
end

File.write(@options.file, @mods.to_yaml)
