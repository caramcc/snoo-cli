#!/usr/bin/env ruby

require 'rubygems'
require 'commander/import'
require 'redd'
require 'paint'
require 'justify'
require 'json'
require 'securerandom'

require_relative '../config.rb'
# require_relative 'config.rb'

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
  c.option '--sortby', 'Some switch that does something'
  c.action do |args, options|
    if args[0].nil?
      subreddit = ask('Subreddit: /r/')
    else
      subreddit = args[0]
    end

    if $valid_sorts.include? args[1]
      sort = args[1]
    else
      sort = 'hot'
    end

    r = Marshal.load(File.read($session))
    r.authorize!

    if sort == 'top'
      top = r.subreddit_from_name(subreddit).get_top.to_a
    elsif sort == 'hot'
      top = r.subreddit_from_name(subreddit).get_hot.to_a
    elsif sort == 'new'
      top = r.subreddit_from_name(subreddit).get_new.to_a
    else #controvertial
      top = r.subreddit_from_name(subreddit).get_controvertial.to_a
    end
    to_cache = {
        :subreddit => subreddit,
        :sortby => sort
    }
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
    File.open($cache, 'w') { |file| file.write(to_cache.to_json) }
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
    if args[0].nil?
      id = ask('Which thread or comment?')
    else
      id = args[0]
    end

    id.length == 7 ? type = :comment : type = :thread

    r = Marshal.load(File.read($session))
    begin
      r.authorize!

      if type == :thread
        cached = JSON.read($cache)
        last_sr = cached['subreddit']
        sort = cached['sortby']

        if sort == 'top'
          all_posts = r.subreddit_from_name(last_sr).get_top.to_a
        elsif sort == 'hot'
          all_posts = r.subreddit_from_name(last_sr).get_hot.to_a
        elsif sort == 'new'
          all_posts = r.subreddit_from_name(last_sr).get_new.to_a
        else #controvertial
          all_posts = r.subreddit_from_name(last_sr).get_controvertial.to_a
        end

        post = all_posts[id.to_i]

        if post.nil?
          puts 'invalid id'
        else
          post.upvote
          puts "Upvoted #{post.author}'s thread ''#{post.title[0..40]}...' in /r/#{post.subreddit}"
          puts "[#{Paint["snoo unvote #{id}", $orangered ]} to clear vote]"
        end
      else
        r.authorize!
        comment = r.by_id("t1_#{id}")
        comment.downvote
        puts "Downvoted #{comment.author}'s comment '#{comment.body[0..40]}...' in /r/#{comment.subreddit}."
        puts "[#{Paint["snoo unvote #{id}", $orangered ]} to clear vote]"
      end
    rescue Redd::Error::ExpiredCode => e
      puts "Your password is incorrect. #{Paint['snoo login', $periwinkle ]} to login, then vote again."

    end
  end
end

command :down do |c|
  c.syntax = 'snoo down [options]'
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

    id.length == 7 ? type = :comment : type = :thread

    r = Marshal.load(File.read($session))
    begin
      r.authorize!
      if type == :thread
        cached = JSON.read($cache)
        last_sr = cached['subreddit']
        sort = cached['sortby']

        if sort == 'top'
          all_posts = r.subreddit_from_name(last_sr).get_top.to_a
        elsif sort == 'hot'
          all_posts = r.subreddit_from_name(last_sr).get_hot.to_a
        elsif sort == 'new'
          all_posts = r.subreddit_from_name(last_sr).get_new.to_a
        else #controvertial
          all_posts = r.subreddit_from_name(last_sr).get_controvertial.to_a
        end

        post = all_posts[id.to_i]

        if post.nil?
          puts 'invalid id'
        else
          post.downvote
          puts "Downvoted #{post.author}'s thread ''#{post.title[0..40]}...' in /r/#{post.subreddit}"
          puts "[#{Paint["snoo unvote #{id}", $orangered ]} to clear vote]"
        end
      else
        r.authorize!
        comment = r.by_id("t1_#{id}")
        comment.downvote
        puts "Downvoted #{comment.author}'s comment '#{comment.body[0..40]}...' in /r/#{comment.subreddit}."
        puts "[#{Paint["snoo unvote #{id}", $orangered ]} to clear vote]"
      end
    rescue Redd::Error::ExpiredCode => e
      puts "Your password is incorrect. #{Paint['snoo login', $periwinkle ]} to login, then vote again."
      break
    end


  end
end
command :unvote do |c|
  c.syntax = 'snoo down [options]'
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

    id.length == 7 ? type = :comment : type = :thread


    r = Marshal.load(File.read($session))
    begin
      r.authorize!

      if type == :thread
        cached = JSON.read($cache)
        last_sr = cached['subreddit']
        sort = cached['sortby']

        if sort == 'top'
          all_posts = r.subreddit_from_name(last_sr).get_top.to_a
        elsif sort == 'hot'
          all_posts = r.subreddit_from_name(last_sr).get_hot.to_a
        elsif sort == 'new'
          all_posts = r.subreddit_from_name(last_sr).get_new.to_a
        else #controvertial
          all_posts = r.subreddit_from_name(last_sr).get_controvertial.to_a
        end

        post = all_posts[id.to_i]

        if post.nil?
          puts 'invalid id'
        else
          post.clear_vote
          puts "Cleared vote for #{post.author}'s thread ''#{post.title[0..40]}...' in /r/#{post.subreddit}"
        end
      else
        r.authorize!
        comment = r.by_id("t1_#{id}")
        comment.clear_vote
        puts "Cleared vote for #{comment.author}'s comment '#{comment.body[0..40]}...' in /r/#{comment.subreddit}."
      end
    rescue Redd::Error::ExpiredCode
      puts "Your password is incorrect. #{Paint['snoo login', $periwinkle ]} to login, then vote again."
      break
    end
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
    r.authorize!

    cached = JSON.parse(File.read($cache))
    last_sr = cached['subreddit']
    sort = cached['sortby']

    if sort == 'top'
      all_posts = r.subreddit_from_name(last_sr).get_top.to_a
    elsif sort == 'hot'
      all_posts = r.subreddit_from_name(last_sr).get_hot.to_a
    elsif sort == 'new'
      all_posts = r.subreddit_from_name(last_sr).get_new.to_a
    else #controvertial
      all_posts = r.subreddit_from_name(last_sr).get_controvertial.to_a
    end


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

    r = Redd.it(:script, $key, $secret, u, p, :user_agent => 'Reddit Command Line Browser v.0.1')

    File.write($session, Marshal.dump(r))

    begin
      r.authorize!
        puts "Logged in as /u/#{u}"
    rescue Redd::Error::ExpiredCode => e
      puts 'Something went wrong. Make sure you typed your password in correctly.'
    end


  end
end

command :logout do |c|
  c.syntax = 'snoo logout [options]'
  c.summary = ''
  c.description = ''
  c.example 'description', 'command example'
  c.option '--some-switch', 'Some switch that does something'
  c.action do |args, options|
    File.delete($session)
    puts 'Logged out.'
  end
end

