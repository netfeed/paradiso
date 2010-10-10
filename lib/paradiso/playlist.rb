# -*- coding: utf-8 -*-
# Copyright (c) 2010 Victor Bergöö
# This program is made available under the terms of the MIT License.

require 'find'

module Paradiso
  class Playlist
    attr_reader :files
  
    include Enumerable

    class << self
      def create_from_file file
        items = []
        
        f = File.open(file, 'r').each_line do |line|
          items << line.sub(/[\r\n]+/, '')
        end
        
        new items, file
      end
    end
    
    def initialize files, path=nil
      @files = []
      @path = path
      @current_idx = -1
            
      files.each do |file|
        begin 
          tmp = []
          
          Find.find(file) do |f|
            tmp << File.expand_path(f) unless File.directory? f
          end
          
          @files += tmp.sort
        rescue Errno::ENOENT => e
          puts "Couldn't find: #{file}"
        end
      end
    end

    def + other
      raise ArgumentError "argument needs to be a of type Playlist" unless other.instance_of? Playlist

      new(files + other.files)
    end

    def << other
      raise ArgumentError "argument needs to be a of type Playlist" unless other.instance_of? Playlist
      
      @files << other.files
    end

    def create delete=false 
      sp = delete ? @current_idx : 0
      
      File.open(@path, 'w') do |f|
        @files[sp..-1].each { |line| f.puts line }
      end
    end
    
    def delete
      File.delete(@path) unless @path.nil?
    end
    
    def each
      @files.each_index do |idx| 
        @current_idx = idx
        yield @files[idx]
      end
    end
    
    def empty?
      @current_idx >= @files.size
    end
    
    def started?
      @current_idx > -1
    end
  end
end
