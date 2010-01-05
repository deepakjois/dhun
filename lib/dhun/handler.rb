require 'json'
module Dhun
  # Handling commands sent by Dhun client
  class Handler
    attr_reader :player

    def initialize
      @player = Dhun::Player.instance
    end

    def play(*args)
      play_enqueue :play_files,args
    end

    def enqueue(*args)
      play_enqueue :enqueue,args
    end
    
    def pause
      pause_resume :pause, ["Dhun is paused at %s","Dhun has already stopped"]
    end

    def resume
      pause_resume :resume, ["Dhun is playing %s","Dhun has already stopped"]
    end

    def status
      status_msg =
      case @player.status
      when :playing then "Dhun is running"
      when :paused  then "Dhun is paused"
      when :stopped then "Dhun has stopped"
      end
      [:success, status_msg, {:now_playing => @player.current, :queue => @player.queue}]
    end

    def history
      status_msg = @player.history.empty? ? "No files in history" : "#{@player.history.size} files in history"
      [:success, status_msg,{:history => @player.history}]
    end

    def next(skip_length=1)
      next_track = @player.next skip_length
      msg = next_track ?  "Dhun is playing #{next_track}" : "Not enough tracks in queue"
      [:success, msg]
    end

    def prev(skip_length=1)
      prev_track = @player.prev skip_length
      msg = prev_track ?  "Dhun is playing #{prev_track}" : "Not enough tracks in history"
      [:success, msg]
    end

    def shuffle
      @player.shuffle
      result =
      @player.queue.empty? ? [:error, "Queue is empty"] : [:success, "Queue is shuffled", {:queue => @player.queue}]
      result
    end

    private

    # for play and enqueue and to keep DRY.
    def play_enqueue(action,args)
      query = Dhun::Query.new(args)

      if query.is_valid?
        files = query.execute_spotlight_query
        result =
        if files.empty?
          [:error, "No Results Found"]
        else
          @player.send(action,files)
          [:success, "#{files.size} files queued", {:files => files}]
        end
      else
        result = [:error, "Invalid query syntax. run dhun help query"]
      end
      result
    end

    # for pause and resume to keep DRY
    def pause_resume(action,messages)
      @player.send action
      result =
      case @player.status
      when :playing then [:success, (messages.first % @player.current)]
      when :stopped then [:error, messages.last]
      end
      result
    end

  end
end
