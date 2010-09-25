require 'optparse'
require 'paradiso/playlist'

module Paradiso
  Options = {
    :fullscreen => false,
    :screen => 0,
    :playlist => false,
    :delete => false,
    :amount => nil,
    :path => nil,
  }
  
  class << self
    def run args
      args.options do |o|
        o.set_summary_indent '  '
        o.banner = "Usage: #{File.basename $0} [Options]"
        o.define_head "A simple mplayer CLI"

        o.on_tail("-h", "--help", "Show this help message.") { puts o; exit }

        o.on("-a", "--amount n", Integer, "Play [n] items") { |amount|
          Options[:amount] = amount
        }
	      
        o.on("-d", "--delete", "Delete items from paylist") { 
          Options[:delete] = true
        }
	      
        o.on("-f", "--fullscreen", "Fullscreen mode") { 
          Options[:fullscreen] = true
        }
	      
        o.on("-n", "--name path", String, "Playlist path to create") { |path|
          Options[:path] = path
        }
	      
        o.on("-p", "--playlist", "The argument is a playlist") { 
          Options[:playlist] = true
        }
	      
        o.on("-s", "--screen n", Integer, "Which screen to play from") { |screen|
          Options[:screen] = screen
        }

        o.parse!

        if Options[:playlist] and args.size > 1 and not Options[:path]
          puts "Error: Can only handle one playlist"
          exit 1
        end
	      
        paradiso = Paradiso.new Options, args
        paradiso.run
      end
    end
  end

  class Paradiso
    def initialize options, args
      @options = options
      @pl_file = nil
      
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
        `mplayer -really-quiet #{options_str} "#{item}"`
      end
    rescue Interrupt
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
      
      str += ['-monitoraspect', '16:9', '-aspect', '16:9']
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
