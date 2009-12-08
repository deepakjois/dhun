module Dhun
  # Handler for commands sent from client
  module DhunServer
    def post_init
      #puts "-- client connected"
    end

    def receive_data data
      @arguments = data.split(/\W+/)
      if @arguments.empty?
       puts "Invalid command" 
      else
        puts "recieved: #{data}"
        @command = @arguments.shift # first word is always the command
        @arguments = data.slice!(@command) && data.strip
        handle_client_request
      end
      close_connection
    end

    def handle_client_request
      handler = Handler.new
      begin
        result = handler.send(@command,*@arguments)
      rescue StandardError => ex
        puts "-- error : #{ex.message}"
        puts ex.backtrace
      end
    end

    def unbind
      #puts "-- client disconnected"
    end
  end
end
