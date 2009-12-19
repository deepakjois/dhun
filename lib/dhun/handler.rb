require 'json'
module Dhun
  # Handling commands sent by Dhun client
  class Handler
    def stop
      result = Result.new :success, "Dhun is stopping"
      Server.stop
      Player.instance.stop
      return result.to_json
    end
    
    def play(*args)
      @player = Player.instance
      q = Query.new(args)
      if q.is_valid?
        files = q.execute_spotlight_query
        if files.empty?
          result = Result.new :error, "No Results Found"
        else
          @player.play_files files
          result = Result.new :success, "#{files.size} files queued for playing",
                              :files => files
        end
      else
          result = Result.new :error, "Invalid query syntax. See dhun -h for correct syntax"                              
      end
      result.to_json
    end

    def enqueue(*args)
      @player = Player.instance
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
      @player = Player.instance
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
      @player = Player.instance
      status_msg = @player.history.empty? ? "No files in history" : "#{@player.history.size} files in history"
      result = Result.new :success, status_msg, :history => @player.history
      result.to_json
    end
    
    def next(skip_length=1)
      @player = Player.instance
      next_track = @player.next skip_length
      msg = next_track ?  "Dhun is playing #{next_track}" : "Not enough tracks in queue"
      result = Result.new :success, msg
      return result.to_json
    end

    def prev(skip_length=1)
      @player = Player.instance
      prev_track = @player.prev skip_length
      msg = prev_track ?  "Dhun is playing #{prev_track}" : "Not enough tracks in history"
      result = Result.new :success, msg
      return result.to_json
    end

    def pause
      @player = Player.instance
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
      @player = Player.instance
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
      @player = Player.instance
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
