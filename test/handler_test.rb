require File.expand_path("test_helper", File.dirname(__FILE__))

context "the Dhun::Handler" do
  setup do
    @handler = Dhun::Handler.new
  end

  context "play method" do

    context "when player return false" do
      setup { stub(@handler.player).play { false } }
      should("return already played") { @handler.play }.equals [:error,"already playing"]
    end

    context "when player return true" do
      setup { stub(@handler.player).play { true } }
      should("return resuming") { @handler.play }.equals [:success,"resuming playback"]
    end

    context "when player return :empty" do
      setup { stub(@handler.player).play { :empty } }
      should("return no queue") { @handler.play }.equals [:error, "no file in queue"]
    end
  end

  context "enqueue method" do
    context "with no file" do
      setup { stub(@handler.player).enqueue([]) { false } }
      should("return none queued") { @handler.enqueue([]) }.equals [:error, "No files queued"]
    end

    context "with one file" do
      setup { stub(@handler.player).enqueue(['one']) { true } }
      should "return number of files queue" do
        @handler.enqueue(['one'])
      end.equals [:success, "1 files queued", {:files => ['one']}]
    end

    context "with two file" do
      setup { stub(@handler.player).enqueue(['one','two']) { true } }
      should "return number of files queue" do
        @handler.enqueue(['one','two'])
      end.equals [:success, "2 files queued", {:files => ['one','two']}]
    end
  end

  context "status method" do
    setup do
      stub(@handler.player).current { "easy" }
      stub(@handler.player).queue { ["goes"] }
    end
    context "when :playing" do
      setup { stub(@handler.player).status { :playing } }
      should "return is running" do
        @handler.status
      end.equals [:success, "Dhun is running", {:current => "easy", :queue => ["goes"]}]
    end

    context "when :paused" do
      setup { stub(@handler.player).status { :paused } }
      should "return is running" do
        @handler.status
      end.equals [:success, "Dhun is paused", {:current => "easy", :queue => ["goes"]}]
    end

    context "when :stopped" do
      setup { stub(@handler.player).status { :stopped } }
      should "return is running" do
        @handler.status
      end.equals [:success, "Dhun has stopped", {:current => "easy", :queue => ["goes"]}]
    end

  end

  context "history method" do

    context "with history empty" do
      setup { stub(@handler.player).history { [] } }
      should("say its empty") { @handler.history }.equals [:error, "No files in history"]
    end

    context "with history" do
      setup { stub(@handler.player).history { ['one'] } }
      should("say its has one") { @handler.history }.equals [:success, "1 files in history" ,{:history => ['one']}]
    end
  end
  
  context "next method" do
    context "with next track" do
      setup do
        stub(@handler.player).current { 'two' }
        stub(@handler.player).next { true }
      end
      should("show next track") { @handler.next }.equals [:success, "Dhun is playing two"]
    end

    context "without next track" do
      setup { stub(@handler.player).next { false } }
      should("show next track") { @handler.next }.equals [:error, "Not enough tracks in queue"]
    end
  end

  context "prev method" do
    context "with prev track" do
      setup do
        stub(@handler.player).current { 'two' }
        stub(@handler.player).prev { true }
      end
      should("show prev track") { @handler.prev }.equals [:success, "Dhun is playing two"]
    end

    context "without prev track" do
      setup { stub(@handler.player).prev { false } }
      should("show no history") { @handler.prev }.equals [:error, "Not enough tracks in history"]
    end
  end

  context "pause method" do
    setup { stub(@handler.player).current {'haunted'} }
    context "when :playing" do
      setup { stub(@handler.player).pause { true } }
      should("return :success") { @handler.pause }.equals [:success, 'Dhun is paused at haunted']
    end
    context "when :paused" do
      setup { stub(@handler.player).pause { false } }
      should("return :error") { @handler.pause }.equals [:error, 'Dhun has already paused or stopped']
    end
    context "when :stopped" do
      setup { stub(@handler.player).pause { false } }
      should("return :error") { @handler.pause }.equals [:error, 'Dhun has already paused or stopped']
    end
  end

  context "resume method" do
    setup { stub(@handler.player).current {'haunted'} }
    context "when :playing" do
      setup { stub(@handler.player).resume { false } }
      should("return :error") { @handler.resume }.equals [:error, 'Dhun has already resumed or stopped']
    end
    context "when :paused" do
      setup { stub(@handler.player).resume { true } }
      should("return :success") { @handler.resume }.equals [:success, 'Dhun is resumed at haunted']
    end
    context "when :stopped" do
      setup { stub(@handler.player).resume { false } }
      should("return :error") { @handler.resume }.equals [:error, 'Dhun has already resumed or stopped']
    end
  end

  context "stop method" do
    setup { stub(@handler.player).current {'haunted'} }
    context "when :playing" do
      setup { stub(@handler.player).stop { true } }
      should("return :success") { @handler.stop }.equals [:success, 'Dhun has stopped']
    end
    context "when :paused" do
      setup { stub(@handler.player).stop { true } }
      should("return :success") { @handler.stop }.equals [:success, 'Dhun has stopped']
    end
    context "when :stopped" do
      setup { stub(@handler.player).stop { false } }
      should("return :error") { @handler.stop }.equals [:error, 'Dhun has already stopped']
    end
  end

  context "shuffle method" do
    setup { stub(@handler.player).current {'haunted'} }
    context "with queue" do
      setup do
        stub(@handler.player).queue { ['one','two'] }
        stub(@handler.player).shuffle { true }
      end
      should("return :success") do
        @handler.shuffle
      end.equals [:success, 'Queue is shuffled', { :queue => ['one','two'] }]
    end
    context "with no queue" do
      setup { stub(@handler.player).shuffle { false } }
      should("return :error") { @handler.shuffle }.equals [:error, 'Dhun cannot shuffle(queue empty, same songs)']
    end
  end

  context "clear method" do
    setup do
      stub(@handler.player).clear { true }
    end
    should("return cleared") { @handler.clear }.equals [:success,'Queue is cleared']
  end

end
