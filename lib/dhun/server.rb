require 'rubygems'
require 'daemons'

dhun_server = File.dirname(__FILE__)+"/dhun_server.rb"
Daemons.run(dhun_server)

# module Dhun
#   class Server
#     @@logger = Logger.instance
# 
#     def initialize(options)
#       @options = options
#       setup_signals
#     end
# 
#     def start
#       # if @options[:daemonize]
#       #    logger.log "Starting Dhun"
#       #   exit if fork
#       #   Process.setsid
#       #   log_file = @options[:log] || @options[:default_log]
#       #   exec("#{ENV['_']} start -l #{log_file} #{@options[:debug] ? "-D" : ""}")
#       # end
#       @@logger.file = @options[:log] if @options[:log]
#       @@logger.log "Starting Dhun"
#       at_exit { remove_socket_file }
#       EventMachine::run {
#         EventMachine::start_server @socket, DhunServer
#       }
#     end
# 
#     # def self.stop
#     #   @@logger.log "Stopping Dhun"
#     #   EventMachine.stop if EventMachine.reactor_running?
#     #   exit
#     # end
# 
#     protected
#     # Register signals:
#     # * calls +stop+ to shutdown gracefully.
#     def setup_signals
#       trap('QUIT') { Server.stop }
#       trap('INT')  { Server.stop }
#       trap('TERM') { Server.stop }
#     end
#      
#     def remove_socket_file
#       File.delete(@options[:socket]) if File.exist?(@options[:socket])
#     end
#   end
# end
