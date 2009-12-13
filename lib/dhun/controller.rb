require 'json'
module Dhun
  class Controller

    attr_accessor :options,:logger
    
    def initialize(options)
      @options = options
      @logger = Logger.instance
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
      abort_if_empty_args(args)
      q = Query.new(args)
      if q.is_valid?
        files = q.execute_spotlight_query
        puts(files.empty? ? "No Results Found" : "#{files.size} Results\n" + files.join("\n"))
      else
        puts "Invalid Query Syntax. Run dhun -h to see right syntax"
      end
    end

    def play(*args)
      abort_if_empty_args(args)
      resp = get_json_response("play", args)
      return unless resp
      # Process response
      case resp.success?
      when true
        puts resp[:message]
        # Print list of files
        print_list resp[:files]
      else
        puts resp[:message]
      end
    end

    def enqueue(*args)
      abort_if_empty_args(args)
      resp = get_json_response("enqueue",args)
      return unless resp
      # Process response
      case resp.success?
      when true
        puts resp[:message]
        # Print list of files
        print_list resp[:files]
      else
        puts resp[:message]
      end
    end

    def status
      resp = get_json_response("status")
      return unless resp
      puts resp[:message]
      if resp.success?
        now_playing = resp[:now_playing]
        queue = resp[:queue]
        puts "Now playing #{now_playing}" if now_playing
        if queue.empty? 
          puts "Queue is empty" 
        else 
          print_list(queue)
        end
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

    def shuffle
      resp = get_json_response("shuffle")
      return unless resp
      # Process response
      case resp.success?
      when true
        puts resp[:message]
        # Print list of files
        print_list resp[:queue]
      else
        puts resp[:message]
      end
    end

    protected
    def send_command(command,arguments=[])
      cmd = { "command" => command, "arguments" => arguments }.to_json
      client = DhunClient.new(@options)
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
  end
end
