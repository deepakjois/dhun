require File.expand_path("test_helper", File.dirname(__FILE__))

context "The Dhun::Runner" do
  setup { @runner = Dhun::Runner.dup }

  context "help option" do
    should("show all Tasks") { capture(:stdout) { @runner.start(['help']) } }.matches(/Tasks/)
  end

  context "start task" do
    should("start the server") do
      capture(:stdout) { @runner.start(['start_server']) }
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

  context "play task" do
    context "with no search query" do
      setup { mock.instance_of(@runner).return_response(:play,[]) { true } }
      should("play the song") { capture(:stdout) {@runner.start(['play'])} }.equals ""
    end
    context "with search query" do
      setup do
        mock.instance_of(@runner).return_response(:clear,[]) { true }
        mock.instance_of(@runner).invoke(anything,anything) { true }
      end
      should("call clear and enqueue") {  capture(:stdout) {@runner.start(['play','testing']) } }.equals ""
    end
  end
  
  context "enqueue task" do
    setup { mock.instance_of(@runner).invoke(anything,anything) { ['one','two'] } }
    context "with no search query" do
      asserts("returns nothing") { capture(:stdout) { @runner.start(['enqueue']) } }.equals ''
    end
    context "with search query" do
      setup do
        
      end
    end
  end
    
  context "status task" do
    context "with response" do
      setup do
        mock.instance_of(@runner).server_running? { true }
        mock.instance_of(@runner).return_response(:status,[:current,:queue]) { {:current => 'one', :queue => ['two']}}
      end
      asserts("says Currently Playing Playing") { capture(:stdout) { @runner.start(['status']) } }.matches(/Currently Playing/)
      asserts("says Queue") { capture(:stdout) { @runner.start(['status']) } }.matches(/Queue/)
      should("show current song") { capture(:stdout) { @runner.start(['status']) } }.matches(/one/)
      should("show queue") { capture(:stdout) { @runner.start(['status']) } }.matches(/two/)
    end
    context "without response" do
      setup { mock.instance_of(@runner).return_response(:status,[:current,:queue]) { false } }
      asserts("returns false") { @runner.start(['status']) }.equals false
    end
  end
  
  context "history task" do
    context "with response" do
      setup do
        mock.instance_of(@runner).server_running? { true }
        mock.instance_of(@runner).return_response(:history,[:history]) { {:history => ['two']}}
      end
      asserts("says History") { capture(:stdout) { @runner.start(['history']) } }.matches(/History/)
      should("show history") { capture(:stdout) { @runner.start(['history']) } }.matches(/two/)
    end
    context "without response" do
      setup { mock.instance_of(@runner).return_response(:history,[:history]) { false } }
      asserts("returns nothing") { @runner.start(['history']) }.equals false
    end
  end
  
  context "shuffle task" do
    context "with response" do
      setup do
        mock.instance_of(@runner).server_running? { true }
        mock.instance_of(@runner).return_response(:shuffle,[:queue]) { {:queue => ['two']}}
      end
      asserts("says Queue") { capture(:stdout) { @runner.start(['shuffle']) } }.matches(/Queue/)
      should("show queue") { capture(:stdout) { @runner.start(['shuffle']) } }.matches(/two/)
    end
    context "without response" do
      setup { mock.instance_of(@runner).return_response(:shuffle,[:queue]) { false } }
      asserts("returns nothing") { @runner.start(['shuffle']) }.equals false
    end
  end

  context "next task" do
    setup { mock.instance_of(@runner).return_response(:next,[],1) { true } }
    asserts("sends next command") { capture(:stdout) { @runner.start(['next']) { true } } }.equals ''
  end
  
  context "prev task" do
    setup { mock.instance_of(@runner).return_response(:prev,[],1) { true } }
    asserts("sends next command") { capture(:stdout) { @runner.start(['prev']) { true } } }.equals ''
  end

  context "pause task" do
    setup { mock.instance_of(@runner).return_response(:pause,[]) { true } }
    asserts("sends pause command") { capture(:stdout) { @runner.start(['pause']) { true } } }.equals ''
  end
  
  context "resume task" do
    setup { mock.instance_of(@runner).return_response(:resume,[]) { true } }
    asserts("sends resume command") { capture(:stdout) { @runner.start(['resume']) { true } } }.equals ''
  end
  
  context "stop task" do
    setup { mock.instance_of(@runner).return_response(:stop,[]) { true } }
    asserts("sends stop command") { capture(:stdout) { @runner.start(['stop']) { true } } }.equals ''
  end
  
end
