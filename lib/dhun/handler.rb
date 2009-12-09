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
      q = Query.new(args.join(" "))
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
      status_msg = (@player.status == :playing) ? "Dhun is running" : "Dhun is paused"
      now_playing = @player.current
      queue = @player.queue
      result = Result.new :success, status_msg, :now_playing => now_playing, :queue => queue
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
      @player.stop
      track = @player.queue.first
      result = Result.new :success, "Dhun is paused. " + (track ? "Next track is #{track}" : "No more tracks in queue.")
      return result.to_json
    end

    def resume
      @player = Player.instance
      track = @player.queue.first
      @player.play
      result = Result.new :success,  (track ? "Dhun is playing #{track}" : "No more tracks in queue.")
      return result.to_json
    end
  end
end
