require File.expand_path("test_helper", File.dirname(__FILE__))

context "the Dhun::Player" do
  setup do
    @player = Dhun::Player.instance
  end

  context "on initialize" do
    asserts("assigns queue").assigns(:queue)
    asserts("assigns history").assigns(:history)
  end

  context "play method" do
    setup do
      stub(DhunExt).play_file(anything) { true }
      stub(@player).notify(anything,:sticky => false) { true }
      @player.queue = ['one']
    end
    should("return false if @status is :playing") do
      @player.status = :playing ; @player.play
    end.equals false
    should "return true if @status is :paused" do
      @player.status = :paused ; @player.play
    end.equals true
    should "return :empty if queue empty" do
      @player.queue = [] ; @player.play
    end.equals :empty
    
    context "while :stopped" do
      setup do
        @player.status = :stopped
        @player.queue = ['one']
        @player.play
      end
      should("load up @history") { @player.history }.equals ['one']
      should("empty queue") { @player.queue }.empty
      should("set current to nil after play") { @player.current }.nil
    end
  end

  context "pause method" do
    setup { stub(DhunExt).pause { true } }
    context "with @status :playing" do
      setup do
        @player.status = :playing ; @player.pause
      end
      should("change status to :paused") { @player.status }.equals :paused
      asserts("return true").equals true
    end

    context "with @status :paused" do
      setup do
        @player.status = :paused ; @player.pause
      end
      asserts("return false").equals false
    end

    context "with @status :stopped" do
      setup do
        @player.status = :stopped ; @player.pause
      end
      asserts("return false").equals false
    end
  end

  context "resume method" do
    setup { stub(DhunExt).resume { true } }
    context "with @status :playing" do
      setup do
        @player.status = :playing ; @player.resume
      end
      asserts("returns false").equals false
    end

    context "with @status :paused" do
      setup do
        @player.status = :paused ; @player.resume
      end
      should("change @status to :playing") { @player.status }.equals :playing
      asserts("returns true").equals true
    end

    context "with @status :stopped" do
      setup do
        @player.status = :stopped ; @player.resume
      end
      asserts("returns false").equals false
    end
  end

  context "stop method" do
    setup { stub(DhunExt).stop { true } }
    context "with @status :playing" do
      setup do
        @player.status = :playing ; @player.stop
      end
      should("change status to :stopped") { @player.status }.equals :stopped
      asserts("returns true").equals true
    end
    
    context "with @status :paused" do
      setup do
        @player.status = :paused ; @player.stop
      end
      should("change status to :stopped") { @player.status }.equals :stopped
      asserts("returns true").equals true
    end
    
    context "with @status :stopped" do
      setup do
        @player.status = :stopped ; @player.stop
      end
      asserts("returns true").equals false
    end
  end

  context "next method" do
    should("with default skip") do
      @player.queue = ["song","another","byebye"]
      @player.next
    end.equals 'song'
    should("with skip = 2") do
      @player.queue = ["song","another","byebye"]
      @player.next(2)
    end.equals 'another'
    should("with skip = 3") do
      @player.queue = ["song","another","byebye"]
      @player.next(3)
    end.equals 'byebye'
    should("with skip > queue") do
      @player.queue = ["song","another","byebye"]
      @player.next(4)
    end.equals false
  end

  context "prev method" do
    setup { stub(@player).play { true } } 
    context "while :stopped" do
      should("with default skip") do
        @player.status = :stopped; @player.history = ["song","another","byebye"]
        @player.prev
      end.equals 'song'
      should("with skip = 2") do
        @player.status = :stopped; @player.history = ["song","another","byebye"]
        @player.prev(2)
      end.equals 'another'
      should("with skip = 3") do
        @player.status = :stopped; @player.history = ["song","another","byebye"]
        @player.prev(3)
      end.equals 'byebye'
      should("with skip > queue") do
        @player.status = :stopped; @player.history = ["song","another","byebye"]
        @player.prev(4)
      end.equals false
    end

    context "while :playing" do
      should("with default skip") do
        @player.status = :playing; @player.history = ["song","another","byebye"]
        @player.prev
      end.equals 'another'
      should("with skip = 2") do
        @player.status = :playing; @player.history = ["song","another","byebye"]
        @player.prev(2)
      end.equals 'byebye'
      # sometimes passes? sometimes doesn't? wtf...
      should("with skip = 3") do
        @player.status = :playing; @player.history = ["song","another","byebye"]
        @player.prev(3)
      end.equals false
      should("with skip > queue") do
        @player.status = :playing; @player.history = ["song","another","byebye"]
        @player.prev(4)
      end.equals false
    end
  end

  context "shuffle method" do
    context "with queue" do
      setup do
        @player.queue = ["song","another","byebye"]
        @player.shuffle
      end
      should("shuffle queue") { @player.queue != ["song","another","byebye"] }.equals true
      should('return true').equals true
    end
    context "with empty queue" do
      setup { @player.queue = [] }
      should("return false") { @player.shuffle }.equals false
    end
    context "with queue of same songs" do
      setup { @player.queue = ['one','one','one'] }
      should("return false") { @player.shuffle }.equals false
    end
  end

  context "enqueue method" do
    setup do
      stub(@player).play { true }
      @player.queue.clear
    end
    context "with file" do
      setup { @player.enqueue(["song","test"]) }
      asserts("queue has 'test'") { @player.queue }.equals ['song','test']
      asserts('return true').equals true
    end
    context "with no file" do
      setup { @player.enqueue([]) }
      asserts('return false').equals false
    end
  end

  context "clear method" do
    setup do
      stub(@player).stop { true }
      @player.queue = ['one','two']
      @player.clear
    end
    asserts("queue is cleared") { @player.queue }.equals []
  end

end
