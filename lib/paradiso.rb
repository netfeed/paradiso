# -*- coding: utf-8 -*-
# Copyright (c) 2010 Victor Bergöö
# This program is made available under the terms of the MIT License.

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift(dir) unless $LOAD_PATH.include? dir

require 'optparse'
require 'yaml'

require 'paradiso/base'

module Paradiso
  VERSION = File.read(File.dirname(__FILE__) + "/../VERSION").chomp
  
  Options = {
    :fullscreen => false,
    :screen => 0,
    :playlist => false,
    :delete => false,
    :amount => nil,
    :path => nil,
    :aspectratio => '16:9',
    :player => 'mplayer',
    :unrar => 'unrar',
    :archive => false,
    :ignore_endings => ['nfo', 'sfv', 'txt'],
    :timestamp => false,
    :autosubs => false,
  }
  
  class << self
    def run
      options = config_file 
      options, args = parse_cl!(options, ARGV)
      
      para = Paradiso.new options, args
      para.run
    rescue ArgumentError => e
      puts "Error: #{e}"
      exit 1
    end
    
    def config_file 
      options = Options.dup
      
      config_file = File.expand_path('~/.paradiso')
      if File.exist? config_file
        yaml = YAML::load(File.open(config_file, 'r').read())
        yaml.inject(options) { |memo, o| memo[o.first.to_sym] = o.last; memo }
      end

      return options
    end

    def parse_cl! options, args
      args.options do |o|
        o.set_summary_indent '  '
        o.banner = "Usage: #{File.basename $0} [Options]"
        o.define_head "Paradiso #{VERSION}: A simple mplayer CLI"

        o.on_tail("-h", "--help", "Show this help message.") { puts o; exit }
        o.on_tail("-v", "--version", "Show version number") { puts "Paradiso %s" % [VERSION]; exit}

        o.on("-a", "--amount n", Integer, "Play [n] items") { |amount|
          options[:amount] = amount
        }

        o.on("-A", "--aspect-ratio n", String, "Aspect ratio - 16:9, 4:3..") { |ratio|
          options[:aspectratio] = ratio
        }

        o.on("-d", "--delete", "Delete items from paylist") { 
          options[:delete] = true
        }

        o.on("-f", "--fullscreen", "Fullscreen mode") { 
          options[:fullscreen] = true
        } 

        o.on("-n", "--name path", String, "Playlist path to create") { |path|
          options[:path] = path
        }

        o.on("-p", "--playlist", "The arguments is playlists") { 
          options[:playlist] = true
        }

        o.on("-s", "--screen n", Integer, "Which screen to play from") { |screen|
          options[:screen] = screen
        }

        o.on("-S", "--autosubs", "Load automatic subs") {
          options[:autosubs] = true
        }

        o.parse!

        return options, args
      end
    end
  end
end
