module Dhun
  # Handling commands sent by Dhun client
  class Handler
    def stop
      Server.stop
      Player.instance.pause
    end
    
    def play(query)
      @player = Player.instance
      @player.empty_queue
      @player.add_from_query query
      @player.play
    end
    
    def next
      @player = Player.instance
      @player.next
    end
  end
end
