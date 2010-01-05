require 'rubygems'
require 'eventmachine'
require 'json'
%w[logger handler result].each { |lib| require File.dirname(__FILE__) + "/#{lib}" }

module Dhun
  # Handler for commands sent from client
  module DhunServer
    @@logger = Dhun::Logger.instance

    def post_init
      #puts "-- client connected"
    end

    def receive_data(data)
      begin
        @@logger.debug data
        cmd = JSON.parse(data)
        handle_client_request cmd["command"], cmd["arguents"]
      rescue StandardError => ex
        @@logger.log "Error parsing command : #{ex.message}"
        @@logger.log ex.backtrace
      ensure
        close_connection true
      end
    end

    def handle_client_request(command,arguments)
      handler = Dhun::Handler.new
      begin
        raise "No Command!" if command.nil?
        result = handler.send(command,*arguments)
        @@logger.debug "Sending #{result}"
        send_data Dhun::Result.new(*result).to_json
      rescue StandardError => ex
        @@logger.log "-- error : #{ex.message}"
        @@logger.log ex.backtrace
      end
    end

    def unbind
      #puts "-- client disconnected"
    end
  end
end

def remove_socket_file(socket)
  File.delete(socket) if File.exist?(socket)
end

def stop!
  Dhun::Logger.instance.log "Stopping Dhun"
  EventMachine.stop if EventMachine.reactor_running?
  exit
end

if ARGV
  Dhun::Logger.instance.file = ARGV[1]
  Dhun::Logger.instance.log "Starting Duhn"
  at_exit { remove_socket_file(ARGV[0]) }
  EventMachine::run do
    puts "Dhun Server at: #{ARGV[0]}"
    trap('QUIT') { stop! }
    trap('INT')  { stop! }
    trap('TERM') { stop! }
    EventMachine::start_server ARGV[0], Dhun::DhunServer
  end
end
