#! /usr/bin/env ruby
# Usage: ruby vlc_to_obs.rb /path/to/output_file.txt

require 'cgi'
require 'io/console'
require 'nokogiri'
require 'typhoeus'

last_song = ''
output_path = ARGV[0]

begin
  password = STDIN.getpass('VLC Server Password: ')

  while true
    content = Typhoeus::Request.get('http://localhost:8080/requests/status.xml', userpwd: ":#{password}")
    doc = Nokogiri::XML(content.body)

    artist = doc.xpath('//information/category[@name="meta"]/info[@name="artist"]')[0]
    title = doc.xpath('//information/category[@name="meta"]/info[@name="title"]')[0]
    current_song = CGI.unescapeHTML("#{artist&.text} - #{title&.text}")

    if last_song != current_song
      puts "[-] Now playing: #{current_song}"
      last_song = current_song
      File.write(output_path, current_song)
    end

    sleep(5)
  end
rescue Interrupt
  exit(0)
end
