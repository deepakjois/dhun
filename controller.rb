module Dhun
  class Controller
    # Command line options passed to the thin script
    attr_accessor :options
    
    IS_NOT_IMPLEMENTED = "is not implemented yet"
    
    def initialize(options)
      @options = options
    end

    def start
      server = Server.new(@options)
      server.start
    end
    
    def stop
      puts "stop #{IS_NOT_IMPLEMENTED}"
    end

    def play(query)
      puts "play #{IS_NOT_IMPLEMENTED}"
    end

    def next
      puts "next #{IS_NOT_IMPLEMENTED}"
    end
    
    def prev
      puts "prev #{IS_NOT_IMPLEMENTED}"
    end
  end
end
