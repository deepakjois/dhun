require 'eventmachine'
require 'daemons'
module Dhun
  class Server
    
    attr_reader :logger

    def initialize(options)
      @options = options
      @socket = options[:socket]
      @logger = Logger.instance
      setup_signals
    end

    def start
      if @options[:daemonize]
         logger.log "Starting Dhun"
        exit if fork
        Process.setsid
        log_file = @options[:log] || @options[:default_log]
        exec("#{ENV['_']} start -l #{log_file} #{@options[:debug] ? "-D" : ""}")
      end
      logger.file = @options[:log] if @options[:log]
      logger.log "Starting Dhun"
      at_exit { remove_socket_file }
      EventMachine::run {
        EventMachine::start_server @socket, DhunServer
      }
    end

    def self.stop
      Logger.instance.log "Stopping Dhun"
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
