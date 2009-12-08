module Dhun
  class Controller

    attr_accessor :options
    
    def initialize(options)
      @options = options
    end

    def start
      server = Server.new(@options)
      server.start
    end
    
    def stop
      client = DhunClient.new(@options)
      res = client.send("stop")
      puts "Dhun is stopped"
    end

    def play(query)
      client = DhunClient.new(@options)
      res = client.send("play #{query}")
    end

    def next
      client = DhunClient.new(@options)
      res = client.send("next")
    end
    
    protected
    def exit_if_server_not_running
      exit unless DhunClient.is_server.running?      
    end
  end
end
