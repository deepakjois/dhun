require 'thor'
require 'json'

module Dhun

  class Runner < Thor
    include Thor::Actions
    include Dhun::Client

    def self.banner(task)
      task.formatted_usage(self).gsub("dhun:runner:","dhun ")
    end


    desc "start_server","Starts the Dhun Server."
    method_option :socket, :type => :string, :default => "/tmp/dhun.sock", :aliases => '-s'
    method_option :log, :type => :string, :default => "/tmp/dhun.log", :aliases => '-l'
    method_option :foreground, :type => :boolean, :default => false, :aliases => '-f'
    method_option :debug, :type => :boolean, :default => false, :aliases => '-D'
    def start_server
      unless server_running?(options[:socket],:silent)
        server_path = File.join File.dirname(__FILE__), 'server.rb'
        cmd = options[:foreground] ? 'run' : 'start'
        say "Starting Dhun", :green
        system("ruby #{server_path} #{cmd} -- #{options[:socket]} #{options[:log]}")
      else
        say "Dhun Server is already running", :yellow
      end
    end

    desc "stop_server","Stop the Dhun Server"
    def stop_server
      Dhun::Player.instance.stop
      server_path = File.join File.dirname(__FILE__), 'server.rb'
      system("ruby #{server_path} stop")
      say "Stopping Dhun", :green
    end

    desc "query SEARCH","Show files matching query. ex: dhun query bob,'the marley'
    \t\t\t See docs for details on query syntax"
    method_option :artist, :type => :string, :aliases => '-a'
    method_option :album, :type => :string, :aliases => '-l'
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
        say "Invalid Query Syntax. See docs for correct syntax", :yellow
      end
      files
    end

    desc "play SEARCH","Play songs matching query. ex: dhun play bob,'the marley'
    \t\t\t See docs for details on query syntax"
    method_option :artist, :type => :string, :aliases => '-a'
    method_option :album, :type => :string, :aliases => '-l'
    method_option :genre, :type => :string, :aliases => '-g'
    method_option :file, :type => :string, :aliases => '-f'
    method_option :title, :type => :string, :aliases => '-t'
    def play(search=nil)
      return return_response(:play,[]) if search.nil? and options.empty?
      invoke :enqueue, [search], options
    end

    desc "enqueue SEARCH","Enqueue songs matching query. ex: dhun enqueue bob,'the marley'
    \t\t\t See docs for details on query syntax"
    method_option :artist, :type => :string, :aliases => '-a'
    method_option :album, :type => :string, :aliases => '-l'
    method_option :genre, :type => :string, :aliases => '-g'
    method_option :file, :type => :string, :aliases => '-f'
    method_option :title, :type => :string, :aliases => '-t'
    def enqueue(search=nil)
      
      # invoke query command and return us all the files found.
      files = invoke :query, [search], options
      if files and !files.empty?
        #prompt for index of song to play and return it in pretty format. cough.
        if files.size == 1 # Dont prompt if result size is 1
          indexes = [0]
        else
          answer = ask "Enter index to queue (ENTER to select all): ",:yellow

          indexes ||=
          case
          when answer.include?(',') then answer.split(',')
          when answer.include?(' ') then answer.split(' ')
          when answer.size >= 1 then answer.to_a
          else
            0..(files.size - 1)
          end
        end
        selected = indexes.map { |index| files[index.to_i] }
        say "selected:",:green
        say_list selected
        
        return_response(:enqueue,nil,selected)
      end
    end

    desc "next COUNT", "Skips to next song by COUNT"
    def next(count=1)
      return_response(:next,[],count.to_i)
    end
    
    desc "prev COUNT", "Skips to previous song by COUNT"
    def prev(count=1)
      return_response(:prev,[],count.to_i)
    end

    desc "status", "Shows the status"
    def status
      return unless server_running?
      response = return_response(:status,[:current,:queue])
      say "Currently Playing:",:magenta
      say response[:current],:white
      say "Queue:",:cyan
      say_list response[:queue]
    end

    desc "history", "Shows the previously played songs"
    def history
      response = return_response(:history,[:history])
      if response[:history]
        say "History:",:cyan
        say_list response[:history]
      end
    end
    
    desc "shuffle", "Shuffles the queue"
    def shuffle
      response = return_response(:shuffle,[:queue])
      if response[:queue]
        say "Queue:",:cyan
        say_list response[:queue]
      end
    end

    desc "pause", "Pauses playing"
    def pause
      return_response(:pause,[])
    end
    
    desc "resume", "Resumes playing"
    def resume
      return_response(:resume,[])
    end
    
    desc "stop", "Stops playing"
    def stop
      return_response(:stop,[])
    end


    private

    # sends command to dhun client
    def send_command(command,arguments=[])
      cmd = { "command" => command.to_s, "arguments" => arguments }.to_json
      send_message(cmd,"/tmp/dhun.sock")
    end

    # send command to the server and retrieve response.
    def get_response(command,arguments=[])
      if server_running?
          resp = send_command(command,arguments)
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
        say("Please start Dhun server first with : dhun start_server", :red) unless verbose == :silent
        return false
      end
    end
    
    #send out the command to server and see what it has to say.
    def return_response(action,keys,argument=[])
      response = get_response(action,argument)
      if response
        color = response.success? ? :red : :cyan
        say response[:message], color
        if keys
          return keys.inject({}) {|base,key| base[key.to_sym] = response[key.to_sym] ; base}
        end
      end
    end

  end
end
