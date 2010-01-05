require File.expand_path("test_helper", File.dirname(__FILE__))

context "the Dhun::Player" do
  setup do
    stub(Dhun::Logger.instance).log(anything) { true }
    stub(Dhun::Logger.instance).debug(anything) { true }
    @player = Dhun::Player.instance
  end

  context "on initialize" do
    asserts("assigns queue").assigns(:queue)
    asserts("assigns history").assigns(:history)
    asserts("assigns queue").assigns(:queue)
    asserts("assigns logger").assigns(:logger)
  end

  context "play method" do
    setup do
      stub(DhunExt).play_file { |file| true }
    end
    
    should("return false if @status is :stopped") do
      @player.status = :playing
      @player.play
    end.equals false
    should("load up @history") do
      @player.status = :stopped
      @player.queue.push "test"
      @player.play
      @player.history
    end.equals ["test"]
    should("empty queue") do
      @player.status = :stopped
      @player.queue.push "test"
      @player.play
      @player.queue
    end.empty
    should("make @current nil") do
      @player.status = :stopped
      @player.queue.push "test"
      @player.play
      @player.current
    end.nil
  end

  context "pause method" do
    setup do
      stub(DhunExt).pause { true }
      @player.status = :playing
      @player.pause
    end
    
    should("change status to :paused") { @player.status }.equals(:paused)
  end

  context "resume method" do
    setup do
      stub(DhunExt).resume { true }
      @player.status = :paused
      @player.resume
    end
    
    should("change status to :playing") { @player.status }.equals(:playing)
  end

  context "stop method" do
    setup do
      stub(DhunExt).stop { true }
      @player.status = :playing
      @player.stop
    end
    
    should("change status to :stopped") { @player.status }.equals(:stopped)
  end

  context "next method" do
    setup do
      stub(@player).stop { true }
      stub(@player).play { true }
      @player.queue.clear
    end
    
    should("return song") do
      @player.queue = ["song","another","byebye"]
      @player.next
    end.equals("song")
    should("return another") do
      @player.queue = ["song","another","byebye"]
      @player.next(2)
    end.equals("another")
    should("return byebye") do
      @player.queue = ["song","another","byebye"]
      @player.next(3)
    end.equals("byebye")
    should("return nil") do
      @player.queue = ["song","another","byebye"]
      @player.next(4)
    end.nil
  end

  context "prev method" do
    setup do
      stub(@player).stop { true }
      stub(@player).play { true }
      @player.history.clear
      @player.queue.clear
    end
    
    context "when playing" do
      setup { @player.status = :playing }
      should("return another") do
        @player.history = ["song","another","byebye"]
        @player.prev
      end.equals("another")
      should("enqueue song") do
        @player.queue.clear
        @player.history = ["song","another","byebye"]
        @player.prev
        @player.queue
      end.equals(["another","song"])
      
      should("return byebye") do
        @player.history = ["song","another","byebye"]
        @player.prev(2)
      end.equals("byebye")
      should("enqueue byebye") do
        @player.queue.clear
        @player.history = ["song","another","byebye"]
        @player.prev(2)
        @player.queue
      end.equals(["byebye","another","song"])
            
      should("return nil") do
        @player.history = ["song","another","byebye"]
        @player.prev(3)
      end.nil
    end
    
    context "when stopped" do
      setup { @player.status = :stopped }
      should("return song") do
        @player.history = ["song","another","byebye"]
        @player.prev
      end.equals("song")
      should("enqueue song") do
        @player.queue.clear
        @player.history = ["song","another","byebye"]
        @player.prev
        @player.queue
      end.equals(["song"])
      
      should("return another") do
        @player.history = ["song","another","byebye"]
        @player.prev(2)
      end.equals("another")
      should("enqueue another") do
        @player.queue.clear
        @player.history = ["song","another","byebye"]
        @player.prev(2)
        @player.queue
      end.equals(["another","song"])
      
      should("return byebye") do
        @player.history = ["song","another","byebye"]
        @player.prev(3)
      end.equals("byebye")
      should("enqueue byebye") do
        @player.queue.clear
        @player.history = ["song","another","byebye"]
        @player.prev(3)
        @player.queue
      end.equals(["byebye","another","song"])
      
      should("return nil") do
        @player.history = ["song","another","byebye"]
        @player.prev(4)
      end.nil
    end
  end

  context "shuffle method" do
    setup do
      @player.queue = ["song","another","byebye"]
      @player.shuffle
    end
    
    should("shuffle queue") { @player.queue != ["song","another","byebye"] }
    
    context "with empty queue" do
      setup { @player.queue = [] }
      should("return false") { @player.shuffle }.equals false
    end
  end

  context "empty_queue method" do
    setup do
      @player.queue.push "test"
      @player.empty_queue
    end
    asserts("@queue is cleared") { @player.queue }.empty
  end

  context "play_files method" do
    setup do
      @player.queue.push "test"
    end
    should("write to logger if empty") { @player.play_files([]) }
    should("clear and queue") do
      @player.play_files(["song"])
      @player.queue
    end.equals ["song"]
  end

  context "enqueue method" do
    setup do
      @player.queue.clear
      @player.enqueue("song")
    end
    asserts("@queue contains 'song'") { @player.queue }.equals ["song"]
  end




end
