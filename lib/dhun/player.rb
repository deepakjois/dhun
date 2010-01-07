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

    # enqueue files and call play.
    def enqueue(files)
      return false if files.empty?
      files.each { |f| self.queue.push f }; play
      return true
    end

    # commence playback
    def play
      return :empty if @queue.empty?
      return false if @status == :playing
      return resume if @status == :paused
      @status = :playing
      @player_thread =
      Thread.new do
        while  @status == :playing and !@queue.empty?
          @current = @queue.shift
          @logger.log "Playing #{@current}"
          DhunExt.play_file @current
          @history.unshift @current
        end
        @status = :stopped
        @current = nil
      end
      return true
    end

    # pause playback
    # only on :playing
    def pause
      if @status == :playing
        @status = :paused
        DhunExt.pause
        @logger.debug "pause"
        return true
      end
      return false
    end

    # resume playback
    # only on :paused
    def resume
      if @status == :paused
        @status = :playing
        DhunExt.resume
        @logger.debug "resume"
        return true
      end
      return false
    end

    # stops the song
    # unless :stopped
    def stop
      unless @status == :stopped
        @status = :stopped
        DhunExt.stop
        # Wait for @player_thread to exit cleanly
        @player_thread.join unless @player_thread.nil?
        @logger.debug "Stopped"
        return true
      end
      return false
    end

    # plays next song on queue.
    # returns next_track or false if invalid
    def next(skip_length = 1)
      unless skip_length > @queue.size
        @logger.debug "next invoked"
        stop
        @queue.shift(skip_length - 1) #skip_length returns starting with first on queue.
        next_track = @queue.first
        play
        return next_track
      end
      return false
    end

    # when :stopped
    # returns the first song in history
    # when :playing
    # returns the second song in history as first song is current song
    def prev(skip_length = 1)
      # skip current track if playing
      if @status == :playing
        stop ; skip_length += 1
      end
      unless skip_length > @history.size
        @logger.debug "previous invoked"
        tracks = @history.shift skip_length
        tracks.each { |track| @queue.unshift track }
        previous = @queue.first
        play
        return previous
      end
      return false
    end

    # shuffle queue if queue is not empty
    # ensures that shuffled queue is not equal to previous queue order
    # NOTE: if they enqueue all the same songs, this will NOT end. should catch that.
    def shuffle
      return false if @queue.empty? or @queue.uniq.size == 1 # this will catch a playlist of same songs
      q = @queue.clone
      while q == @queue
        @queue.size.downto(1) { |n| @queue.push @queue.delete_at(rand(n)) }
      end
      @logger.debug @queue
      return true
    end
  end
end
