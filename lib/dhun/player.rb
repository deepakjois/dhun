require 'singleton'
require 'dhun_ext'
module Dhun
  class Player
    include Singleton

    attr_reader :queue
    attr_reader :status
    attr_reader :current

    def initialize
      @queue = []
    end

    def empty_queue
      stop
      @queue.clear
    end

    def enqueue(file)
      @queue.push(file)
    end
    
    def play_files(files)
      if files.empty?
        puts "Empty List"
      else
        stop
        empty_queue
        @queue = files
        play
      end
    end

    def play
      return if @status == :playing
      @status = :playing
      @player_thread = Thread.new do
        while  @status == :playing and !queue.empty?          
          @current = @queue.shift
          puts "playing #{@current}"
          DhunExt.play_file @current
        end
        @status = :stopped
        puts "Player is stopped"
      end
    end

    def stop
      @status = :stopped
      @current = nil
      DhunExt.pause_play
      # Wait for @player_thread to exit cleanly
      @player_thread.join unless @player_thread.nil?
    end

    def next
      stop # stops current track
      play # start playing with the next track
    end
  end
end
