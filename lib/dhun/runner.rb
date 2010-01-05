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
      unless server_running?(options[:socket],:silent)
        # Dhun::Server.new(options).start
        server_path = File.join File.dirname(__FILE__), 'server.rb'
        cmd = options[:daemonize] ? 'start' : 'run'
        say "Starting Dhun", :green
        system("ruby #{server_path} #{cmd} -- #{options[:socket]} #{options[:log]}")
      else
        say "Dhun Server is already running", :yellow
      end
    end

    desc "stop","stop the Dhun Server"
    def stop
      # send_command(:stop) if server_running?
      Dhun::Player.instance.stop
      server_path = File.join File.dirname(__FILE__), 'server.rb'
      system("ruby #{server_path} stop")
      say "Stopping Dhun", :green
    end

    desc "query FILTER",<<-EOF
    query for selected songs via filter. or regular string

    available filters: album,artist,genre,file,title

    i.e FILTER='album:test artist:bob' or FILTER='Czech'
    filters longer than one word enclose in quotes. i.e FILTER=' "album:the big album"'
    EOF
    def query(arguments)
      # run_command(:query,arguments) if server_running?
      query = Dhun::Query.new(arguments)
      if query.is_valid?
        files = query.execute_spotlight_query
        say "Query:", :yellow

        if files.empty?
          say "No Results Found", :red
        else
          say "#{files.size} Results", :green
          say files.join("\n"), :white
        end
      else
        say "Invalid Query Syntax. Run dhun help query for syntax", :yellow
      end
    end

    desc "play FILTER","play songs that match the FILTER. run dhun help query for filter details."
    def play(arguments)
      resp = get_json_response("play", arguments)
      if resp
        if resp.success?
          say resp[:message],:cyan
          say_list resp[:files]
        else
          say resp[:message], :magenta
        end
      end
    end

    protected

    # sends command to dhun client
    def send_command(command,arguments=[],socket = "/tmp/dhun.sock")
      cmd = { "command" => command.to_s, "arguments" => arguments }.to_json
      Dhun::DhunClient.send(cmd,socket)
    end

    def get_json_response(command,args=[])
      begin
        resp = send_command(command,args)
        return Dhun::Result.from_json_str(resp)
      rescue
        say "Invalid Response From Server",:red
        Dhun::Logger.instance.debug "Invalid Response From Server"
        return nil
      end
    end

    def abort_if_empty_args(args)
      abort "You must pass in atleast one argument" if args.empty?
    end

    def say_list(list)
      list.each { |item| say(item,:white) }
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
    def server_running?(socket = "/tmp/dhun.sock",verbose = :verbose)
      if Dhun::DhunClient.is_dhun_server_running?(socket)
        return true
      else
        say("Please start Dhun server first with : dhun start", :red) unless verbose == :silent
        return false
      end
    end

  end
end
