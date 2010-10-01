# -*- coding: utf-8 -*-
# Copyright (c) 2010 Victor Bergöö
# This program is made available under the terms of the MIT License.

require 'popen4'
require 'paradiso/playlist'

module Paradiso
  class Paradiso
    def initialize options, args
      @options = options
      @pl_file = nil
      @pid = nil

      if @options[:playlist] and args.size > 1 and not @options[:path]
        puts "Error: Can only handle one playlist"
        exit 1
      end
      
      if @options[:playlist] and not @options[:path]
        @pl_file = args.pop
        @playlist = Playlist.create_from_file @pl_file
      else
        @playlist = Playlist.new args
      end
    end
    
    def run
      options_str = handle_options
      amount = 0
      
      @playlist.each do |item|
        if @options[:amount]
          break if amount == @options[:amount]
          amount += 1
        end

        puts "Playing #{item}"
        
        cmd = "mplayer #{options_str} \"#{item}\""
        POpen4::popen4(cmd) do |stdout, stderr, stdin, pid|
          @pid = pid
        end
      end
    rescue Interrupt
      Process.kill(9, @pid) if @pid
      puts "Exiting..."
    ensure
      if (@options[:path] or @options[:delete]) and @options[:playlist]
        file = @options[:path] ? @options[:path] : @pl_file
        @playlist.create file, @options[:delete]
      end
    end
    
    private

    def handle_options
      str = []
      ratio = @options[:aspectratio]
      
      str += ['-monitoraspect', ratio, '-aspect', ratio]
      if @options[:fullscreen]
        str << "-fs"
      end
      
      # more platforms needs to be added
      if RUBY_PLATFORM =~ /darwin10/
        str += ['-vo', 'corevideo:device_id=%d' % [@options[:screen]]]
      end
      
      str.join " "
    end
  end
end

