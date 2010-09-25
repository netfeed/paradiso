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
        
        new items
      end
    end
    
    def initialize files
      @files = []
      @current_idx = -1
            
      files.each do |file|
        begin 
          tmp = []
          
          Find.find(file) do |f|
            tmp << f unless File.directory? f
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
    
    def create path, delete=false 
      # can this be made in a nicer way?
      start_point = case @current_idx
        when -1 then 0
        when 0 then 1
        else @current_idx + 1
      end
      start_point = 0 unless delete
      
      File.open(path, 'w') do |f|
        @files[start_point..-1].each { |line| f.puts line }
      end
    end
    
    def each
      @files.each_index do |idx| 
        yield @files[idx]
        @current_idx = idx
      end
    end
  end
end
