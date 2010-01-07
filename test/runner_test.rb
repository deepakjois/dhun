require File.expand_path("test_helper", File.dirname(__FILE__))

context "The Dhun::Runner" do
  setup { @runner = Dhun::Runner.dup }

  context "help option" do
    should("show all Tasks") { capture(:stdout) { @runner.start(['help']) } }.matches(/Tasks/)
  end

  context "start task" do
    should("daemonize the server") do
      capture(:stdout) { @runner.start(['start_server','-d']) }
    end.matches(/Starting Dhun/)
  end

  context "stop task" do
    should("stop the server") do
      capture(:stdout) { @runner.start(['stop_server']) }
    end.matches(/Stopping Dhun/)
  end

  context "query task" do

    should("have found no results") do
      mock.instance_of(Dhun::Query).execute_spotlight_query { [] }
      capture(:stdout) {@runner.start(['query','notgoingtoquery'])}
    end.matches(/No Results Found/)

    should("show description") do
      capture(:stdout) { @runner.start(['help','query']) }
    end.matches(/query SEARCH/)

    should "show 2 results" do
      mock.instance_of(Dhun::Query).execute_spotlight_query { ["first","second"] }
      capture(:stdout) { @runner.start(['query','bobby']) }
    end.matches(/2 Results/)

    should "show the results" do
      mock.instance_of(Dhun::Query).execute_spotlight_query { ["first"] }
      capture(:stdout) { @runner.start(['query','bobby']) }
    end.matches(/first/)
  end

end
