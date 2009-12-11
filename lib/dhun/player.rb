require 'singleton'
require 'dhun_ext'
module Dhun
  class Player
    include Singleton

    attr_reader :queue
    attr_reader :status
    attr_reader :current

    attr_reader :logger

    def initialize
      @queue = []
      @logger = Logger.instance
      @status = :stopped
    end

    def empty_queue
      stop
      @queue.clear
    end

    
    def play_files(files)
      if files.empty?
        logger.log "Empty Queue"
      else
        stop
        empty_queue
        files.each { |f| self.queue.push f }
        play
      end
    end

    def enqueue(files)
      files.each { |f| self.queue.push f }
      play
    end

    def play
      return unless self.status == :stopped
      @status = :playing
      @player_thread = Thread.new do
        while  @status == :playing and !queue.empty?          
          @current = @queue.shift
          logger.log "Playing #{@current}"
          DhunExt.play_file @current
        end
        @status = :stopped
        logger.log "Finished playing #{@current}"
        @current = nil
      end
    end

    def pause
      if @status == :playing
        @status = :paused
        DhunExt.pause
      end
    end

    def resume
      if @status == :paused
        @status = :playing
        DhunExt.resume
      end
    end

    def stop
      @status = :stopped
      @current = nil
      DhunExt.stop
      # Wait for @player_thread to exit cleanly
      @player_thread.join unless @player_thread.nil?
    end

    def next
      stop # stops current track
      next_track = @queue.first
      play # start playing with the next track
      return next_track
    end

    def shuffle
      return if @queue.empty?
      s = @queue.size
      s.downto(1) { |n| @queue.push @queue.delete_at(rand(n)) }
      logger.debug @queue
    end
  end
end
