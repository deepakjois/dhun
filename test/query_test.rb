require File.expand_path("test_helper", File.dirname(__FILE__))

context "the Dhun::Query" do
  
  context "on initialize" do
    asserts("assigns @query_args") { Dhun::Query.new("meow") }.assigns(:query_args)
    asserts("assigns @is_valid") { Dhun::Query.new("meow") }.assigns(:is_valid)
  end
  
  context "parse method" do
    
  end
  
  context "is_valid? method" do
    
  end
  
  context "filter? method" do
    
  end
  
end