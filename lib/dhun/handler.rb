require 'json'
module Dhun
  # Handling commands sent by Dhun client
  class Handler
    def stop
      result = Result.new :success, "Dhun is stopping"
      Server.stop
      Player.instance.pause
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
                   when :stopped then "Dhun is stopped"
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
    
    def next(*args)
      @player = Player.instance
      next_track = @player.next
      result = Result.new :success, (next_track ?  "Dhun is playing #{next_track}" : "No More Tracks")
      return result.to_json
    end

    def pause
      @player = Player.instance
      @player.pause
      case @player.status 
      when :paused
        result = Result.new :success, "Dhun is paused at #{@player.current}"
      when :stopped
        result = Result.new :error, "Dhun is already stopped"
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
        result = Result.new :error, "Dhun is already stopped"
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
