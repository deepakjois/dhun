module Dhun
  class Controller

    attr_accessor :options
    
    def initialize(options)
      @options = options
    end

    def start
      server = Server.new(@options)
      if DhunClient.is_dhun_server_running?(@options[:socket])
        puts "Dhun is already running"
      else
        server.start
      end
    end
    
    def stop
      client = DhunClient.new(@options)
      res = client.send("stop")
      puts "Dhun is stopped"
    end
    
    def query(query_string)
      q = Query.new(query_string)
      if q.is_valid?
        files = q.execute_spotlight_query
        puts(files.empty? ? "No Results Found" : "#{files.size} Results\n" + files.join("\n"))
      else
        puts "Invalid Query Syntax. Run dhun -h to see right syntax"
      end
    end

    def play(query_string)
      client = DhunClient.new(@options)
      res = client.send("play #{query_string}")
    end

    def next
      client = DhunClient.new(@options)
      res = client.send("next")
    end
  end
end
