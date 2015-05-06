#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require 'redd'
require 'paint'
require 'justify'
require 'json'

require_relative '../config.rb'
# require_relative 'config.rb'

program :version, '0.0.1'
program :description, 'Browse reddit from your command line'
 
command :r do |c|
  c.syntax = 'snoo r [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    if args[0].nil?
      subreddit = ask('Subreddit: /r/')
    else
      subreddit = args[0]
    end
    sr = $r.subreddit_from_name(subreddit)
    top = sr.get_top.to_a
    top.select! {|post| post.is_self}
    unless $nsfw_ok
      top.select! {|post| !post.over_18}
    end
    id = 0
    top.each do |post|
      enable_paging
      puts "[#{Paint["snoo up/down #{id}", $periwinkle ]} to up/down vote]"
      puts "    [ #{post.score} points ] "
      puts "    [ by #{post.author} ] \n"
      puts Paint[post.title, $orangered]
      puts ''
      post.selftext.split("\n").each do |line|
        puts "    #{line.justify(80)}"
      end
      puts "\n[#{Paint["snoo comments #{id}", $periwinkle]} to read comments]"
      puts "\n--------\n"
      id += 1
    end

    m = JSON.dump top.to_a
    File.open($cache, 'w') {|f| f.write(m) }

  end
end

command :u do |c|
  c.syntax = 'snoo u [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    puts 'not yet implemented'
  end
end

command :up do |c|
  c.syntax = 'snoo up [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    puts 'not yet implemented'
  end
end

command :down do |c|
  c.syntax = 'snoo down [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    puts 'not yet implemented'
  end
end

command :comments do |c|
  c.syntax = 'snoo comments [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    if args[0].nil?
      post_id = ask('Which number?')
    else
      post_id = args[0]
    end
    posts = JSON.parse(File.read($cache))
    puts posts
  end
end

command :open do |c|
  c.syntax = 'snoo open [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    puts 'not yet implemented'
  end
end

command :login do |c|
  c.syntax = 'snoo login [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    puts 'not yet implemented'
  end
end

command :logout do |c|
  c.syntax = 'snoo logout [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    puts 'not yet implemented'
  end
end

