require 'json'
module Dhun
  # Handling commands sent by Dhun client
  class Handler
    attr_reader :player
    
    def initialize
      @player = Dhun::Player.instance
    end

    def play(*args)
      query = Dhun::Query.new(args)

      if query.is_valid?
        files = query.execute_spotlight_query
        result =
        if files.empty?
          [:error, "No Results Found"]
        else
          @player.play_files files
          [:success, "#{files.size} files queued", {:files => files}]
        end
      else
        result = [:error, "Invalid query syntax. run dhun help query"]
      end
      result
    end

    def enqueue(*args)
      q = Query.new(args.join(" "))
      if q.is_valid?
        files = q.execute_spotlight_query
        if files.empty?
          result = Result.new :error, "No Results Found"
        else
          @player.enqueue files
          result = Result.new :success, "#{files.size} files queued for playing.",
          :files => files
        end
      else
        result = Result.new :error, "Invalid query syntax. See dhun -h for correct syntax"
      end
      result.to_json
    end

    def status
      status_msg = case @player.status
      when :playing then "Dhun is running"
      when :paused  then "Dhun is paused"
      when :stopped then "Dhun has stopped"
      end
      now_playing = @player.current
      queue = @player.queue
      result = Result.new :success, status_msg, :now_playing => now_playing, :queue => queue
      result.to_json
    end

    def history
      status_msg = @player.history.empty? ? "No files in history" : "#{@player.history.size} files in history"
      result = Result.new :success, status_msg, :history => @player.history
      result.to_json
    end

    def next(skip_length=1)
      next_track = @player.next skip_length
      msg = next_track ?  "Dhun is playing #{next_track}" : "Not enough tracks in queue"
      result = Result.new :success, msg
      return result.to_json
    end

    def prev(skip_length=1)
      prev_track = @player.prev skip_length
      msg = prev_track ?  "Dhun is playing #{prev_track}" : "Not enough tracks in history"
      result = Result.new :success, msg
      return result.to_json
    end

    def pause
      @player.pause
      case @player.status
      when :paused
        result = Result.new :success, "Dhun is paused at #{@player.current}"
      when :stopped
        result = Result.new :error, "Dhun has already stopped"
      end
      return result.to_json
    end

    def resume
      @player.resume
      case @player.status
      when :playing
        result = Result.new :success, "Dhun is playing #{@player.current}"
      when :stopped
        result = Result.new :error, "Dhun has already stopped"
      end
      return result.to_json
    end

    def shuffle
      @player.shuffle
      if @player.queue.empty?
        result = Result.new :error, "Queue is empty"
      else
        result = Result.new :success, "Queue is shuffled", :queue => @player.queue
      end
      return result.to_json
    end
  end
end
