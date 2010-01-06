require 'thor'
require 'json'

module Dhun

  class Runner < Thor
    include Thor::Actions
    include Dhun::Client

    desc "start","starts the Dhun Server."
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

    desc "query SEARCH",<<-EOF
    query for selected songs via search term and optional fields.
    multipler search terms must be seperate by ','
    ex: bob,marley,johnson
    queries for terms longer than one word must be enclosed in ''
    ex: 'bob marley','jack johson'
    EOF
    method_option :artist, :type => :string, :aliases => '-ar'
    method_option :album, :type => :string, :aliases => '-al'
    method_option :genre, :type => :string, :aliases => '-g'
    method_option :file, :type => :string, :aliases => '-f'
    method_option :title, :type => :string, :aliases => '-t'
    def query(search=nil)
      search = search.nil? ? nil : search.split(',')
      query = Dhun::Query.new(search,options)
      if query.is_valid?
        
        #make the prompt pretty. i think.
        opts = options.collect {|field,value| "#{field}:#{value}" }.join(" ")
        term = search.nil? ? '[nil]' : search.join(",")
        say "Querying: #{term} | #{opts}", :cyan

        # commence the query, and respond as so.
        files = query.execute_spotlight_query
        if files.empty?
          say "No Results Found", :red
        else
          say "#{files.size} Results", :green
          say_list files
        end
      else
        say "Invalid Query Syntax. Run dhun help query for syntax", :yellow
      end
      files
    end

    desc "play SEARCH",<<-EOF
    play songs that match the SEARCH. run dhun help query for filter details.
    once querying is complete, designate the index of song to play
    ex:
      Enter song index to play:
      1
    multiple indexes can be seperate by ',' or spaces
    ex:
      1,2,3 OR 1 2 3
    EOF
    method_option :artist, :type => :string, :aliases => '-ar'
    method_option :album, :type => :string, :aliases => '-al'
    method_option :genre, :type => :string, :aliases => '-g'
    method_option :file, :type => :string, :aliases => '-f'
    method_option :title, :type => :string, :aliases => '-t'
    def play(search=nil)
      
      # invoke query command and return us all the files found.
      files = invoke :query, [search], options
      if files
        
        #prompt for index of song to play and return it in pretty format. cough.
        answer = ask "Enter index to play: ",:yellow
        indexes = answer.include?(',') ? answer.split(',') : answer.split(' ')
        selected = indexes.map { |index| files[index.to_i] }
        say "selected:",:green
        say_list selected
        
        #send out the command to server and see what it has to say.
        response = get_response(:play,selected)
        if response
          say(response[:message],:red) unless response.success?
          say(response[:message],:cyan)
        end
      end
    end

    protected

    # sends command to dhun client
    def send_command(command,arguments=[])
      cmd = { "command" => command.to_s, "arguments" => arguments }.to_json
      send_message(cmd,"/tmp/dhun.sock")
    end

    # send command to the server and retrieve response.
    def get_response(command,arguments=[])
      if server_running?
          resp = send_command(command,arguments)
          say resp.inspect.to_s
          return Dhun::Result.from_json_str(resp)
      end
    end
    
    # prints out list with each index value
    # in pretty format! (contrasting colors)
    def say_list(list)
      list.each_with_index do |item,index|
        color = index.even? ? :white : :cyan
        say("#{index} : #{item}",color)
      end
    end

    # check to see if Dhun Server is running.
    # asks to start Dhun server if not
    # takes argument :silent to quiet its output.
    # need to make the socket choices more flexible
    def server_running?(socket = "/tmp/dhun.sock",verbose = :verbose)
      socket ||= "/tmp/dhun.sock"
      if is_server?(socket)
        return true
      else
        say("Please start Dhun server first with : dhun start", :red) unless verbose == :silent
        return false
      end
    end

  end
end
