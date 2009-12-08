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
          result = Result.new :success, "#{files.size} files queued for playing",
                              :files => files
          @player.play_files files
        end
      else
          result = Result.new :error, "Invalid query syntax. See dhun -h for correct syntax"                              
      end
      result.to_json
    end
    
    def next(*args)
      @player = Player.instance
      next_track = @player.next
      result = Result.new :success, (next_track || "No More Tracks")
      return result.to_json
    end
  end
end
