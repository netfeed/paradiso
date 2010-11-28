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

      if args.empty?
        puts "Error: needs atleast one argument"
        exit 1
      end

      if @options[:playlist] and not @options[:path]
        args.each do |pl|
          unless File.exist? pl
            puts "Warning: playlist %s does not exist" % [pl]
            next
          end

          begin
            @playlist << Playlist.create_from_file(pl, @options[:ignore_endings])
          rescue ArgumentError => e
            puts "Warning: #{e}"
          end
        end
      else
        @playlist << Playlist.new(args, @options[:path], @options[:ignore_endings])
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
        if (@options[:path] or @options[:delete]) and @options[:playlist]
          if pl.started? and not pl.empty?
            pl.create @options[:delete]
          elsif pl.empty?
            pl.delete
          end
        end
      end
    end
    
    private

    def handle_options
      str = []
      ratio = @options[:aspectratio]
      
      str += ['-aspect', ratio]
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

        puts "#{timestamp}Playing #{item}"
        
        play_command = player item
        item = "-" if item =~ /(rar|r\d{2})$/
        
        cmd = "#{play_command} #{options_str} \"#{item}\""
        POpen4::popen4(cmd) do |stdout, stderr, stdin, pid|
          @pid = pid
        end
      end
      
      true
    end
    
    def player file
      return @options[:player] unless file =~ /(rar|r\d{2})$/
      return "#{@options[:unrar]} p -inul #{file} | #{@options[:player]}"
    end
    
    def timestamp
      return "" unless @options[:timestamp]
      Time.now.strftime("%Y-%m-%d %H:%M - ")
    end
  end
end

