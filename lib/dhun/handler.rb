module Dhun
  # Handling commands sent by Dhun client
  class Handler
    def stop
      Server.stop
      Player.instance.pause
    end
    
    def play(query_string)
      @player = Player.instance
      q = Query.new(query_string)
      if q.is_valid?
        @player.play_files q.execute_spotlight_query
      else
        puts "Invalid Query Syntax. Rhun dhun -h to see right syntax"
      end
    end
    
    def next
      @player = Player.instance
      @player.next
    end
  end
end
