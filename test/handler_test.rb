require File.expand_path("test_helper", File.dirname(__FILE__))

context "the Dhun::Handler" do
  setup do
    @handler = Dhun::Handler.new
  end

  context "play method" do

    context "with status :playing" do
      setup do
        stub(@handler.player).play { true }
        stub(@handler.player).status { :playing }
      end
      should("return already played") { @handler.play }.equals [:error,"already playing"]
    end

    context "with status :paused" do
      setup do
        stub(@handler.player).play { true }
        stub(@handler.player).status { :paused }
      end
      should("return resuming") { @handler.play }.equals [:success,"resuming playback"]
    end

    context "with status :stopped" do
      setup do
        stub(@handler.player).play { true }
        stub(@handler.player).status { :stopped }
      end
      should("return playing") { @handler.play }.equals [:success,"resuming playback"]
    end
  end


  context "play_files method" do

    context "with no files" do
      setup do
        stub(@handler.player).play_files([]) { true }
      end
      should("return none queued") { @handler.play_files([]) }.equals [:error, "No files queued"]
    end

    context "with one file" do
      setup do
        stub(@handler.player).play_files(['test']) { true }
      end
      should("return 1 queued") do
        @handler.play_files(['test'])
      end.equals [:success, "1 files queued",{:files => ['test']}]
    end

    context "with two files" do
      setup do
        stub(@handler.player).play_files(['one','two']) { true }
      end
      should "return number of files queue" do
        @handler.play_files(['one','two'])
      end.equals [:success, "2 files queued", {:files => ['one','two']}]
    end
  end

  context "enqueue method" do
    context "with no file" do
      setup do
        stub(@handler.player).enqueue([]) { true }
      end
      should("return none queued") { @handler.enqueue([]) }.equals [:error, "No files queued"]
    end

    context "with one file" do
      setup do
        stub(@handler.player).enqueue(['one']) { true }
      end
      should "return number of files queue" do
        @handler.enqueue(['one'])
      end.equals [:success, "1 files queued", {:files => ['one']}]
    end

    context "with two file" do
      setup do
        stub(@handler.player).enqueue(['one','two']) { true }
      end
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
      end.equals [:success, "Dhun is running", {:now_playing => "easy", :queue => ["goes"]}]
    end

    context "when :paused" do
      setup { stub(@handler.player).status { :paused } }
      should "return is running" do
        @handler.status
      end.equals [:success, "Dhun is paused", {:now_playing => "easy", :queue => ["goes"]}]
    end

    context "when :stopped" do
      setup { stub(@handler.player).status { :stopped } }
      should "return is running" do
        @handler.status
      end.equals [:success, "Dhun has stopped", {:now_playing => "easy", :queue => ["goes"]}]
    end

  end

  context "history method" do

    context "with history empty" do
      setup { stub(@handler.player).history { [] } }
      should "say its empty" do
        @handler.history
      end.equals [:success, "No files in history" ,{:history => []}]
    end

    context "with history" do
      setup { stub(@handler.player).history { ['one'] } }
      should "say its has one" do
        @handler.history
      end.equals [:success, "1 files in history" ,{:history => ['one']}]
    end
  end

  context "next method" do

    context "with next track" do
      setup do
        stub(@handler.player).next(1) { 'two' }
      end
      should "show next track" do
        @handler.next
      end.equals [:success, "Dhun is playing two"]
    end

    context "without next track" do
      setup do
        stub(@handler.player).next(1) { nil }
      end
      should "show next track" do
        @handler.next
      end.equals [:success, "Not enough tracks in queue"]
    end
  end

  context "prev method" do
    context "with next track" do
      setup do
        stub(@handler.player).prev(1) { 'two' }
      end
      should "show next track" do
        @handler.prev
      end.equals [:success, "Dhun is playing two"]
    end

    context "without next track" do
      setup do
        stub(@handler.player).prev(1) { nil }
      end
      should "show next track" do
        @handler.prev
      end.equals [:success, "Not enough tracks in history"]
    end
  end

  context "pause method" do
    setup do
      stub(@handler.player).pause { true }
    end

    context "when :playing" do
      setup do
        stub(@handler.player).status { :playing }
        stub(@handler.player).current { "haunted" }
      end
      should "show paused" do
        @handler.pause
      end.equals [:success, "Dhun is paused at haunted"]
    end

    context "when :stopped" do
      setup do
        stub(@handler.player).status { :stopped }
      end
      should "show already stopped" do
        @handler.pause
      end.equals [:error, "Dhun has already stopped"]
    end

  end

  context "resume method" do
    setup do
      stub(@handler.player).resume { true }
    end

    context "when :paused" do
      setup do
        stub(@handler.player).status { :paused }
        stub(@handler.player).current { "haunted" }
      end
      should "show playing" do
        @handler.resume
      end.equals [:success, "Dhun is playing haunted"]
    end

    context "when :stopped" do
      setup do
        stub(@handler.player).status { :stopped }
      end
      should "show already stopped" do
        @handler.resume
      end.equals [:error, "Dhun has already stopped"]
    end
  end

  context "shuffle method" do
    setup do
      stub(@handler.player).shuffle { true }
    end

    context "with queue" do
      setup { stub(@handler.player).queue { ['one','two'] } }
      should "return empty" do
        @handler.shuffle
      end.equals [:success, "Queue is shuffled", { :queue => ['one','two'] } ]
    end

    context "with empty queue" do
      setup { stub(@handler.player).queue { [] } }
      should "return empty" do
        @handler.shuffle
      end.equals [:error, "Queue is empty"]
    end

  end

end
