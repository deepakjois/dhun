require File.expand_path("test_helper", File.dirname(__FILE__))

context "the Dhun::Handler" do
  setup do
    @handler = Dhun::Handler.new
  end
  context "play method" do

    context "with no match" do
      setup do
        mock.instance_of(Dhun::Query).is_valid? { true }
        mock.instance_of(Dhun::Query).execute_spotlight_query { "" }
      end
      should("return No Result Found") { @handler.play('test') }.equals [:error, "No Results Found"]
    end

    context "with match" do
      setup do
        mock.instance_of(Dhun::Query).is_valid? { true }
        mock.instance_of(Dhun::Query).execute_spotlight_query { ['one'] }
        stub(@handler.player).play_files(['one']) { true }
      end
      should "return number of files queue" do
        @handler.play('test')
      end.equals [:success, "1 files queued", {:files => ['one']}]
    end

    context "with no valid query" do
      setup { mock.instance_of(Dhun::Query).is_valid? { false } }
      should "return invalid query" do
        @handler.play('test')
      end.equals [:error, "Invalid query syntax. run dhun help query"]
    end
  end

  context "enqueue method" do
    context "with no match" do
      setup do
        mock.instance_of(Dhun::Query).is_valid? { true }
        mock.instance_of(Dhun::Query).execute_spotlight_query { "" }
        stub(@handler.player).enqueue("") { true }
      end
      should("return No Result Found") { @handler.enqueue('test') }.equals [:error, "No Results Found"]
    end

    context "with match" do
      setup do
        mock.instance_of(Dhun::Query).is_valid? { true }
        mock.instance_of(Dhun::Query).execute_spotlight_query { ['one'] }
        stub(@handler.player).enqueue(['one']) { true }
      end
      should "return number of files queue" do
        @handler.enqueue('test')
      end.equals [:success, "1 files queued", {:files => ['one']}]
    end

    context "with no valid query" do
      setup { mock.instance_of(Dhun::Query).is_valid? { false } }
      should "return invalid query" do
        @handler.enqueue('test')
      end.equals [:error, "Invalid query syntax. run dhun help query"]
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
