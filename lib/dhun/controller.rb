require 'json'
module Dhun
  class Controller

    attr_accessor :options
    
    def initialize(options)
      @options = options
    end

    def start
      server = Server.new(@options)
      if DhunClient.is_dhun_server_running?(@options[:socket])
        puts "Dhun is already running"
      else
        server.start
      end
    end
    
    def stop
      send_command("stop")
    end
    
    def query(*args)
      q = Query.new(args.join(' '))
      if q.is_valid?
        files = q.execute_spotlight_query
        puts(files.empty? ? "No Results Found" : "#{files.size} Results\n" + files.join("\n"))
      else
        puts "Invalid Query Syntax. Run dhun -h to see right syntax"
      end
    end

    def play(*args)
      resp = get_json_response("play", args)
      return unless resp
      # Process response
      case resp.success?
      when true
        puts resp[:message]
        # Print list of files
        resp[:files].each do |f|
          puts f
        end
      else
        puts resp[:message]
      end
    end

    def next(*args)
      resp = get_json_response("next")
      puts resp[:message] if resp
    end

    def pause
      resp = get_json_response("pause")
      puts resp[:message] if resp
    end

    def resume
      resp = get_json_response("resume")
      puts resp[:message] if resp
    end

    protected
    def send_command(command,arguments=[])
      cmd = { "command" => command, "arguments" => arguments }.to_json
      client = DhunClient.new(@options)
      resp = client.send(cmd)
    end

    def get_json_response(command,*args)
      begin 
         resp = send_command(command,args)
         return Result.from_json_str(resp)
      rescue 
        puts "Invalid Response From Server"
        puts $!
        return nil
      end
    end
  end
end
