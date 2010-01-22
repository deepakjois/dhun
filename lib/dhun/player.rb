require 'singleton'
require 'dhun_ext'
require 'growl'
require 'mp3info'
module Dhun
  class Player
    include Singleton
    include Growl

    attr_accessor :queue,:history,:status,:current

    def initialize
      @queue,@history = [],[]
      @status = :stopped
    end

    # enqueue files and call play.
    def enqueue(files)
      return false if files.empty?
      files.each { |f| self.queue.push f }; play
      return true
    end
    
    # clear the queue and stops playback
    def clear
      stop ; @queue.clear
      return true
    end

    # commence playback
    def play
      return :empty if @queue.empty?
      return false if @status == :playing
      return resume if @status == :paused
      @status = :playing
      @player_thread = play_thread
      return true
    end

    # pause playback
    # only on :playing
    def pause
      if @status == :playing
        @status = :paused
        DhunExt.pause
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
        return true
      end
      return false
    end

    # plays next song on queue.
    # returns next_track or false if invalid
    def next(skip_length = 1)
      unless skip_length > @queue.size
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
      return true
    end
    
    private
    
    # returns song in Artist - Title format
    # if no tags or non-existent, return its input
    # TODO
    def mp3_tag(song)
      return song unless File.exists?(song)
      Mp3Info.open(song) do |mp3| 
        artist = mp3.tag.artist ; title = mp3.tag.title
        (artist and title) ? "#{artist} - #{title}" : song
      end
    end
    
    # play method's player thread
    def play_thread
      Thread.new do
        while  @status == :playing and !@queue.empty?
          @current = @queue.shift
          notify mp3_tag(@current),:sticky => false
          DhunExt.play_file @current
          @history.unshift @current
        end
        @status = :stopped
        @current = nil
      end
    end
    
  end
end
