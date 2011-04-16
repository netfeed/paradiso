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
    def config_file 
      options = Options.dup
      
      config_file = File.expand_path('~/.paradiso')
      if File.exist? config_file
        yaml = YAML::load(File.open(config_file, 'r').read())
        yaml.inject(options) { |memo, o| memo[o.first.to_sym] = o.last; memo }
      end

      return options
    end
  end
end
