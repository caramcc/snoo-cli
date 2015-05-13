#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require 'redd'
require 'paint'
require 'justify'
require 'json'
require 'securerandom'

require_relative '../config.rb'

program :version, '0.0.1'
program :description, 'Browse reddit from your command line'

default_command :login

def display_children(children, op, tabs=0)
  children.each do |child|
    if child.kind == 'Listing'
      puts "snoo moar #{child.id}"
    else
      child.author == op ? author = "/u/#{Paint[child.author, $periwinkle ]}" : author = '/u/' << child.author
      puts '   ' * (tabs) << "[ #{child.score} points ] [ by /u/#{author} ] [#{Paint["snoo up/down #{child.id}", $orangered ]} to up/down vote]"
      puts "\n"
      child.body.split("\n").each do |line|
        # line.gsub!('&gt;', '>')
        puts '   ' * (tabs) << "#{line.justify(80-tabs)}"
      end
      puts '   ' * (tabs) << "--------\n\n"
      display_children(child.replies, op, tabs+=1)
    end
  end
end
 
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

    r = Marshal.load(File.read($session))

    sr = r.subreddit_from_name(subreddit)
    top = sr.get_top.to_a
    to_cache = "subreddit_from_name('#{subreddit}').get_top.to_a"
    top.select! {|post| post.is_self}
    unless $nsfw_ok
      top.select! {|post| !post.over_18}
    end
    id = 0
    top.each do |post|
      enable_paging
      puts "[#{Paint["snoo up/down #{id}", $periwinkle ]} to up/down vote]"
      puts "    [ #{post.score} points ] "
      puts "    [ by /u/#{post.author} ] \n"
      puts Paint[post.title, $orangered]
      puts ''
      post.selftext.split("\n").each do |line|
        line.gsub!('&gt;', '>')
        puts "    #{line.justify(80)}"
      end
      puts "\n[#{Paint["snoo comments #{id}", $periwinkle]} to read comments]"
      puts "\n--------\n"
      id += 1
    end
    File.open($cache, 'w') { |file| file.write(to_cache) }

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
      id = ask('Which thread?')
    else
      id = args[0]
    end

    r = Marshal.load(File.read($session))
    # to_execute = File.read($cache)
    all_posts = r.subreddit_from_name('talesfromtechsupport').get_top.to_a


    post = all_posts[id.to_i]

    if post.nil?
      puts 'invalid id'
    else
      enable_paging
      puts display_children(post.comments, post.author)
    end

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
    u = ask('Username? /u/')
    p = ask('Password:  ') { |q| q.echo = false }

    File.write($session, Marshal.dump(Redd.it(:script, $key, $secret, u, p, :user_agent => 'Reddit Command Line Browser v.0.1')))
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

