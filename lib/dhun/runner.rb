require 'thor'
require 'json'

module Dhun
  
  class Runner < Thor
    include Thor::Actions

    desc "start","start the Dhun Server"
    method_option :socket, :type => :string, :default => "/tmp/dhun.sock", :aliases => '-s'
    method_option :log, :type => :string, :default => "/tmp/dhun.log", :aliases => '-l'
    method_option :daemonize, :type => :boolean, :default => false, :aliases => '-d'
    method_option :debug, :type => :boolean, :default => false, :aliases => '-D'
    def start
      unless server_running?(:silent)
        Dhun::Server.new(options).start
      else
        say "Dhun Server is already running", :yellow
      end
    end
    
    desc "stop","stop the Dhun Server"
    def stop
      send_command(:stop) if server_running?
    end
    
    desc "query FILTER", 
    "query for selected songs via filter. i.e genre:world album:gypsy or regular query like Czech"
    def query(arguments)
      run_command(:query,arguments) if server_running?
    end

    protected

    # sends command to dhun client
    def send_command(command,arguments=[])
      cmd = { "command" => command.to_s, "arguments" => arguments }.to_json
      client = Dhun::DhunClient.new(@options)
      resp = client.send(cmd)
    end

    def get_json_response(command,args=[])
      begin
         resp = send_command(command,args)
         return Result.from_json_str(resp)
      rescue
        puts "Invalid Response From Server"
        logger.debug $!
        return nil
      end
    end

    def abort_if_empty_args(args)
      abort "You must pass in atleast one argument" if args.empty?
    end

    def print_list(list)
      list.each { |item| puts item }
    end

    # send commands to Controller
    def run_command(command,arguments)
      @logger.log_level = :debug if @dhun_options[:debug]
      Dhun::Controller.new(@dhun_options).send(command,*arguments)
    end
    
    # check to see if Dhun Server is running.
    # asks to start Dhun server if not
    # takes argument :silent to quiet its output.
    # need to make the socket choices more flexible
    def server_running?(verbose = :verbose)
      if Dhun::DhunClient.is_dhun_server_running?("/tmp/dhun.sock")
        return true
      else
        say("Please start Dhun server first with : dhun start", :red) unless verbose == :silent
        return false
      end
    end

  end
end