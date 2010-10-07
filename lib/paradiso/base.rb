# -*- coding: utf-8 -*-
# Copyright (c) 2010 Victor Bergöö
# This program is made available under the terms of the MIT License.

require 'popen4'
require 'paradiso/playlist'

module Paradiso
  class Paradiso
    def initialize options, args
      @playlist = []
      @options = options
      @pid = nil
      @amount_played = 0

      if @options[:playlist] and not @options[:path]
        args.each do |pl|
          unless File.exist? pl
            puts "Error: playlist %s does not exist" % [pl]
            next
          end
          
          @playlist << Playlist.create_from_file(pl)
        end
      else
        @playlist << Playlist.new(args, @options[:path])
      end
    end
    
    def run
      @playlist.each do |pl|
        break unless play? pl
      end
    rescue Interrupt
      Process.kill(9, @pid) if @pid
      puts "Exiting..."
    ensure
      @playlist.each do |pl|
        if @options[:delete] and pl.empty?
          pl.delete
        end

        if ((@options[:path] or @options[:delete]) and @options[:playlist]) and not pl.empty?
          pl.create @options[:delete]
        end
      end
    end
    
    private

    def handle_options
      str = []
      ratio = @options[:aspectratio]
      
      str += ['-monitoraspect', ratio, '-aspect', ratio]
      str << "-fs" if @options[:fullscreen]
      
      # more platforms needs to be added
      if RUBY_PLATFORM =~ /darwin10/
        str += ['-vo', 'corevideo:device_id=%d' % [@options[:screen]]]
      end
      
      str.join " "
    end
    
    def play? playlist
      options_str = handle_options
      
      playlist.each do |item|
        unless @options[:amount].nil?
          return false if @amount_played == @options[:amount]
          @amount_played += 1
        end

        puts "Playing #{item}"

        cmd = "mplayer #{options_str} \"#{item}\""
        POpen4::popen4(cmd) do |stdout, stderr, stdin, pid|
          @pid = pid
        end
      end
      
      true
    end
  end
end

