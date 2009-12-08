require 'json'
module Dhun
  # Handler for commands sent from client
  module DhunServer
    def post_init
      #puts "-- client connected"
    end

    def receive_data data
      begin
       puts data
       cmd = JSON.parse(data)
       @command = cmd["command"]
       @arguments = cmd["arguments"]
       handle_client_request
      rescue StandardError => ex
        puts "Error parsing command : #{ex.message}"
        puts ex.backtrace
      ensure
        close_connection true
      end
    end

    def handle_client_request
      handler = Handler.new
      begin
        if @command.nil?
          raise "Command Not Found"
        end
        result = handler.send(@command,*@arguments)
        puts "Sending #{result}"
        send_data result
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
