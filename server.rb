require 'eventmachine'
module Dhun
  class Server
    
    def initialize(options)
      @options = options
      @socket = options[:socket]
      setup_signals
    end

    def start
      puts "Starting Dhun"
      at_exit { remove_socket_file }
      EventMachine::run {
        EventMachine::start_server @socket, DhunServer
      }
    end

    def self.stop
      puts "Stopping Dhun"
      EventMachine.stop if EventMachine.reactor_running?
      exit
    end


    protected
    # Register signals:
    # * calls +stop+ to shutdown gracefully.
    def setup_signals
      trap('QUIT') { Server.stop }
      trap('INT')  { Server.stop }
      trap('TERM') { Server.stop }
    end
     
    def remove_socket_file
      File.delete(@socket) if File.exist?(@socket)
    end
  end
end
