require 'json'
module Dhun
  # Handler for commands sent from client
  module DhunServer
    def post_init
      #puts "-- client connected"
    end

    def receive_data data
      @logger ||= Logger.instance
      begin
       @logger.debug data
       cmd = JSON.parse(data)
       @command = cmd["command"]
       @arguments = cmd["arguments"]
       handle_client_request
      rescue StandardError => ex
        @logger.log "Error parsing command : #{ex.message}"
        @logger.log ex.backtrace
      ensure
        close_connection true
      end
    end

    def handle_client_request
      @logger ||= Logger.instance
      handler = Handler.new
      begin
        if @command.nil?
          raise "Command Not Found"
        end
        result = handler.send(@command,*@arguments)
        @logger.debug "Sending #{result}"
        send_data result
      rescue StandardError => ex
        @logger.log "-- error : #{ex.message}"
        @logger.log ex.backtrace
      end
    end

    def unbind
      #puts "-- client disconnected"
    end
  end
end
