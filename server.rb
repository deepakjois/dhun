require 'eventmachine'
module Dhun
  class Server
    
    def initialize(options)
      @options = options
      @socket = options[:socket]
      setup_signals
    end

    def start
      at_exit { stop }
      puts "Starting Dhun"
      EventMachine::run {
        EventMachine::start_server @socket, DhunServer
      }
    end

    def stop
      puts "Stopping Dhun"
      remove_socket_file
      exit
    end

    protected
    # Register signals:
    # * INT calls +stop+ to shutdown gracefully.
    # * TERM calls <tt>stop!</tt> to force shutdown.    
    def setup_signals
      trap('QUIT') { stop }
      trap('INT')  { stop }
      trap('TERM') { stop }
    end
    
    def remove_socket_file
      File.delete(@socket) if File.exist?(@socket)
    end
  end
end
