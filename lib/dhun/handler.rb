require 'json'
module Dhun
  # Handling commands sent by Dhun client
  class Handler
    attr_reader :player

    def initialize
      @player = Dhun::Player.instance
    end

    def play
      response =
      case @player.play
      when false then [:error,"already playing"]
      when true then [:success, "resuming playback"]
      when :empty then [:error, 'no file in queue']
      end
      response
    end

    def enqueue(files)
      perform_action :enqueue, files, 
      :success => ["#{files.size} files queued", {:files => files}],
      :error => ["No files queued"]
    end

    def pause
      perform_action :pause,nil, 
      :success => "Dhun is paused at #{@player.current}",
      :error => "Dhun has already paused or stopped"
    end

    def resume
      perform_action :resume,nil,
      :success => "Dhun is resumed at #{@player.current}",
      :error => "Dhun has already resumed or stopped"
    end

    def stop
      perform_action :stop,nil,
      :success => "Dhun has stopped",
      :error => "Dhun has already stopped"
    end
    
    def next(skip_length=1)
      next_prev :next, 'queue',skip_length
    end

    def prev(skip_length=1)
      next_prev :prev, 'history',skip_length
    end
    
    def shuffle
      perform_action :shuffle,nil,
      :success => ['Queue is shuffled', { :queue => @player.queue }],
      :error => 'Dhun cannot shuffle(queue empty, same songs)'
    end

    def clear
      perform_action :clear,nil,
      :success => "Queue is cleared",
      :error => "Queue is not cleared"
    end


    def status
      status_msg =
      case @player.status
      when :playing then "Dhun is running"
      when :paused  then "Dhun is paused"
      when :stopped then "Dhun has stopped"
      end
      [:success, status_msg, {:current => @player.current, :queue => @player.queue}]
    end

    def history
      return [:success, "#{@player.history.size} files in history",{:history => @player.history}] unless @player.history.empty?
      return [:error, "No files in history"]
    end

    private

    # get response
    def perform_action(action, arg=nil, message={})
      result = arg.nil? ? @player.send(action) : @player.send(action,arg)
      return [:error,message[:error]].flatten unless result
      return [:success,message[:success]].flatten
    end

    #next and previous method
    def next_prev(action,message,skip_length)
      track = @player.send(action,skip_length)
      return [:success, "Dhun is playing #{track}"] if track
      return [:error, "Not enough tracks in #{message}"]
    end

  end
end
