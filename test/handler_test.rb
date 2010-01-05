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
      setup do
        mock.instance_of(Dhun::Query).is_valid? { true }
        mock.instance_of(Dhun::Query).execute_spotlight_query { ['one'] }
      end
      should "return number of files queue" do
        Dhun::Handler.new.play('test')
      end.equals [:success, "1 files queued", {:files => ['one']}]
    end

    context "with no valid query" do
      setup { mock.instance_of(Dhun::Query).is_valid? { false } }
      should "return invalid query" do
        Dhun::Handler.new.play('test')
      end.equals [:error, "Invalid query syntax. run dhun help query"]
    end
  end

  context "enqueue method" do

  end

  context "status method" do

  end

  context "history method" do

  end

  context "next method" do

  end

  context "prev method" do

  end

  context "pause method" do

  end

  context "resume method" do

  end

  context "shuffle method" do

  end

end
