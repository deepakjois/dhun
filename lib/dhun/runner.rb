require 'thor'

module Dhun
  
  class Runner < Thor
    include Thor::Actions

    # overload start method to initialize dhun_options
    def self.start(given_args=ARGV, config={})
      @dhun_options = {
        :socket => "/tmp/dhun.sock",
        :default_log => "/tmp/dhun.log",
        :debug => false
      }
      @logger = Dhun::Logger.instance
      super
    end

    desc "query FILTER", 
    "query for selected songs via filter. i.e genre:world album:gypsy or regular query like Czech"
    def query(arguments)
      run_command(:query,arguments) if server_running?
    end

    private

    # send commands to Controller
    def run_command(command,arguments)
      @logger.log_level = :debug if @dhun_options[:debug]
      Dhun::Controller.new(@dhun_options).send(command,*arguments)
    end
    
    # check to see if Dhun Server is running.
    # asks to start Dhun server if not
    def server_running?
      if Dhun::DhunClient.is_dhun_server_running?(@options[:socket])
        return true
      else
        say "Please start Dhun server first with : dhun start", :red
        return false
      end
    end

  end
end