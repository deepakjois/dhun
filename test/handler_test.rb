require File.expand_path("test_helper", File.dirname(__FILE__))

context "the Dhun::Handler" do

  context "play method" do

    context "with no match" do
      setup do
        mock.instance_of(Dhun::Query).is_valid? { true }
        mock.instance_of(Dhun::Query).execute_spotlight_query { "" }
      end
      should("return No Result Found") { Dhun::Handler.new.play('test') }.equals [:error, "No Results Found"]
    end

    context "with match" do
      asserts("fail need to mock Dhun::Player") { false }
      # though this passes fine.
      # setup do
      #   mock.instance_of(Dhun::Query).is_valid? { true }
      #   mock.instance_of(Dhun::Query).execute_spotlight_query { ['one'] }
      # end
      # should "return number of files queue" do
      #   Dhun::Handler.new.play('test')
      # end.equals [:success, "1 files queued", {:files => ['one']}]
    end

    context "with no valid query" do
      setup { mock.instance_of(Dhun::Query).is_valid? { false } }
      should "return invalid query" do
        Dhun::Handler.new.play('test')
      end.equals [:error, "Invalid query syntax. run dhun help query"]
    end
  end

  context "enqueue method" do
    context "with no match" do
      setup do
        mock.instance_of(Dhun::Query).is_valid? { true }
        mock.instance_of(Dhun::Query).execute_spotlight_query { "" }
      end
      should("return No Result Found") { Dhun::Handler.new.enqueue('test') }.equals [:error, "No Results Found"]
    end

    context "with match" do
      setup do
        mock.instance_of(Dhun::Query).is_valid? { true }
        mock.instance_of(Dhun::Query).execute_spotlight_query { ['one'] }
      end
      should "return number of files queue" do
        Dhun::Handler.new.enqueue('test')
      end.equals [:success, "1 files queued", {:files => ['one']}]
    end

    context "with no valid query" do
      setup { mock.instance_of(Dhun::Query).is_valid? { false } }
      should "return invalid query" do
        Dhun::Handler.new.enqueue('test')
      end.equals [:error, "Invalid query syntax. run dhun help query"]
    end
  end

  context "status method" do
    setup do
      Dhun::Player.instance.current = "easy"
      Dhun::Player.instance.queue = ["goes"]
    end
    context "when :playing" do
      setup { Dhun::Player.instance.status = :playing }
      should "return is running" do
        Dhun::Handler.new.status
      end.equals [:success, "Dhun is running", {:now_playing => "easy", :queue => ["goes"]}]
    end

    context "when :paused" do
      setup { Dhun::Player.instance.status = :paused }
      should "return is running" do
        Dhun::Handler.new.status
      end.equals [:success, "Dhun is paused", {:now_playing => "easy", :queue => ["goes"]}]
    end

    context "when :stopped" do
      setup { Dhun::Player.instance.status = :stopped }
      should "return is running" do
        Dhun::Handler.new.status
      end.equals [:success, "Dhun has stopped", {:now_playing => "easy", :queue => ["goes"]}]
    end

  end

  context "history method" do

    context "with history empty" do
      setup { Dhun::Player.instance.history = [] }
      should "say its empty" do
        Dhun::Handler.new.history
      end.equals [:success, "No files in history" ,{:history => []}]
    end

    context "with history" do
      setup { Dhun::Player.instance.history = ['one'] }
      should "say its has one" do
        Dhun::Handler.new.history
      end.equals [:success, "1 files in history" ,{:history => ['one']}]
    end
  end

  context "next method" do

    asserts("fail need to mock Dhun::Player") { false }
    # context "with next track" do
    #   setup do
    #     Dhun::Player.instance.queue = ['one','two']
    #   end
    #   should "show next track" do
    #     Dhun::Handler.new.next
    #   end.equals [:success, "Dhun is playing two"]
    # end

  end

  context "prev method" do
    asserts("fail need to mock Dhun::Player") { false }
  end

  context "pause method" do
    asserts("fail need to mock Dhun::Player") { false }
  end

  context "resume method" do
    asserts("fail need to mock Dhun::Player") { false }
  end

  context "shuffle method" do
    asserts("fail need to mock Dhun::Player") { false }
  end

end
