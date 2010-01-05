require File.expand_path("test_helper", File.dirname(__FILE__))

context "The Dhun::Runner" do
  setup { @runner = Dhun::Runner.dup }

  context "help option" do
    should("show all Tasks") { capture(:stdout) { @runner.start(['help']) } }.matches(/Tasks/)
  end

  # context "display list" do
  #   should("display") { @runner.start(['help']) }
  # end

  # context "start task" do
    #   # context "when server running" do
    #   #   setup { capture(:stdout) { @runner.start(['start']) } }
    #   #
    #   #   should("state it is already running") do
    #   #     capture(:stdout) { @started.start(['start']) }
    #   #   end.matches(/already running/)
    #   # end
    #
    #   context "when server down" do
    #     setup { capture(:stdout) { @runner.start(['stop']) } }
    #
    #     should("run the server") { capture(:stdout) { @runner.start(['start']) } }.matches(/Starting Dhun/)
    #   end
    #
  #   should("start the server daemonized") do
  #     capture(:stdout) { @runner.start(['start','-d']) }
  #   end.matches(/Starting Dhun/)
  # end

  context "stop task" do
    context "when server is down" do
      should "state to start the server" do
        capture(:stdout) { @runner.start(['stop']) }
      end.matches(/Please start Dhun server first with/)
    end
    context "when server is up" do
      # setup { @runner.start(['start']) }
      should("stop the server") { capture(:stdout) { @runner.start(['stop']) } }.matches(/Stopping Dhun/)
    end
  end

  context "query task" do
    should("ask to start server when server stopped") do
      capture(:stdout) {@runner.start(['query','notgoingtoquery'])}
    end.matches(/Please start Dhun server/)

    should("show description") do
      capture(:stdout) { @runner.start(['help','query']) }
    end.matches(/songs/)
  end


end
