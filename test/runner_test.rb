require File.expand_path("test_helper", File.dirname(__FILE__))

context "The Dhun Runner" do
  setup { @runner = Dhun::Runner.dup }

  context "start method" do
    setup { capture(:stdout) { @runner.start(['help']) } }
    asserts("dhun_option is set") { @runner }.assigns(:dhun_options)
  end

  context "help option" do
    should("show all Tasks") { capture(:stdout) { @runner.start(['help']) } }.matches(/Tasks/)
  end

  context "query task" do

    should("ask to start server when server stopped") do
      capture(:stdout) {@runner.start(['query','notgoingtoquery'])}
    end.matches(/Please start Dhun server/)

    should("show description") do
      capture(:stdout) { @runner.start(['help','query']) }
    end.matches(/songs/)

    # context "(with server started)" do
    #   setup { capture(:stdout) { @runner.start(['start']) } }
    #   
    #   should("not find a match for song") do
    #     capture(:stdout) { @runner.start(['query','notgoingtofindamatchwiththisstringforsure']) }
    #   end.matches(/No Results Found/)
    # 
    # end
  end


end
