require 'rubygems'
require 'eventmachine'
require 'json'
%w[handler logger player query result].each {|lib| require File.dirname(__FILE__) + "/#{lib}"}
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
        puts data.inspect.to_s
        cmd = JSON.parse(data)
        handle_client_request cmd["command"], cmd["arguments"]
      rescue StandardError => ex
        @@logger.log ex.message
        @@logger.log ex.backtrace
        send_data Dhun::Result.new(:error,ex.message).to_json
      ensure
        close_connection true
      end
    end

    def handle_client_request(command,arguments)
      handler = Dhun::Handler.new
      raise "No Command!" if command.nil?
      result =
      if arguments and arguments != [] # this check is on the sloppy side...
        handler.send command, arguments
      else
        handler.send command
      end
      @@logger.debug "Sending #{result}"
      if result
        puts result.inspect.to_s
      else
        puts 'nil'
      end
      send_data Dhun::Result.new(*result).to_json
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
  Dhun::Logger.instance.log "Starting Dhun"
  at_exit { remove_socket_file(ARGV[0]); stop! }
  EventMachine::run do
    puts "Dhun Server at: #{ARGV[0]}"
    trap('QUIT') { stop! }
    trap('INT')  { stop! }
    trap('TERM') { stop! }
    EventMachine::start_server ARGV[0], Dhun::DhunServer
  end
end
