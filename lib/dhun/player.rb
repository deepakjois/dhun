require 'singleton'
require 'dhun_ext'
module Dhun
  class Player
    include Singleton

    attr_accessor :queue,:history,:status,:current,:logger

    def initialize
      @queue,@history = [],[]
      @logger = Logger.instance
      @status = :stopped
    end

    def empty_queue
      stop; @queue.clear
    end

    def play_files(files)
      if files.empty?
        @logger.log "Empty Queue"
      else
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
      return false unless self.status == :stopped
      @status = :playing
      @player_thread = Thread.new do
        while  @status == :playing and !queue.empty?
          @current = @queue.shift
          @logger.log "Playing #{@current}"
          DhunExt.play_file @current
          @history.unshift @current
        end
        @status = :stopped
        @current = nil
      end
    end

    def pause
      if @status == :playing
        @status = :paused
        DhunExt.pause
        @logger.debug "pause"
      end
    end

    def resume
      if @status == :paused
        @status = :playing
        DhunExt.resume
        @logger.debug "resume"
      end
    end

    def stop
      @status = :stopped
      DhunExt.stop
      # Wait for @player_thread to exit cleanly
      @player_thread.join unless @player_thread.nil?
      @logger.debug "Stopped"
    end

    def next(skip_length = 1)
      @logger.debug "Switching to next"
      unless @queue.size < skip_length
        stop # stops current track
        @queue.shift(skip_length - 1) # Remove skip_length-1 tracks
        next_track = @queue.first
        play # start playing with the next track
      end
      return next_track
    end

    # when :stopped
    # returns the first song in history
    # when :playing
    # returns the second song in history as first song is current song
    def prev(skip_length = 1)
      @logger.debug "Switching to prev"
      unless (@history.size < skip_length and @status == :stopped) or (@history.size <= skip_length and @status == :playing )
        unless @status == :stopped
          stop
          skip_length += 1 # history has increased by one to skip current
        end
        tracks = @history.shift skip_length
        @logger.debug tracks
        tracks.each { |t| @queue.unshift t }
        prev_track = @queue.first
        play # start playing with the next track
      end
      return prev_track
    end

    def shuffle
      return false if @queue.empty?
      @queue.size.downto(1) { |n| @queue.push @queue.delete_at(rand(n)) }
      @logger.debug @queue
    end
  end
end
