require File.expand_path("test_helper", File.dirname(__FILE__))

context "the Dhun::Query" do
  setup { @query = Dhun::Query.new("album:test genre:techno") }

  context "on initialize" do
    asserts("assigns @query_args").assigns(:query_args)
    asserts("assigns @is_valid").assigns(:is_valid)
  end

  context "create_filter_query method" do
    should("return one query") do
      @query.create_filter_query("album:test",Dhun::Query::MD_ITEMS.clone)
    end.equals "kMDItemAlbum == 'test'wc"
    
    should("return two queries") do
      q = ["album:test","genre:techno"]
      @query.create_filter_query(q,Dhun::Query::MD_ITEMS.clone)
    end.equals "kMDItemAlbum == 'test'wc && kMDItemMusicalGenre == 'techno'wc"
    
    should "throw out non-matching filters" do
      q = ["album:test","booger:big"]
      @query.create_filter_query(q,Dhun::Query::MD_ITEMS.clone)
    end.equals "kMDItemAlbum == 'test'wc"
    
    asserts("delete keys at mappings") do
      mapping = Dhun::Query::MD_ITEMS.clone
      @query.create_filter_query("album:test",mapping)
      mapping.include? :kMDItemAlbum
    end.equals false
    
  end

  context "create_string_query method" do
    should("return queries for one string") do
      mappings = [:kMDItemAlbum, :kMDItemAuthors]
      @query.create_string_query("holy", mappings)
    end.equals "( kMDItemAlbum == 'holy'wc || kMDItemAuthors == 'holy'wc )"
    
    should "return queries for two strings" do
      mappings = [:kMDItemAlbum]
      @query.create_string_query(["holy","cannoli"],mappings)
    end.equals "( kMDItemAlbum == 'holy'wc ) && ( kMDItemAlbum == 'cannoli'wc )"
  end
  
  context "create_spotlight_query method" do
    
    should "create a query with filter_query" do
      filter_query = "kMDItemAlbum == 'test'wc"
      @query.create_spotlight_query(filter_query,"")
    end.equals "kMDItemContentTypeTree == 'public.audio' && kMDItemAlbum == 'test'wc"
    
    should "create a query with string_query" do
      string_query = "( kMDItemAuthors == 'holy'wc )"
      @query.create_spotlight_query("",string_query)
    end.equals "kMDItemContentTypeTree == 'public.audio' && ( kMDItemAuthors == 'holy'wc )"
    
    should "create a query with filter_query and string_query" do
      filter_query = "kMDItemAlbum == 'test'wc"
      string_query = "( kMDItemAuthors == 'holy'wc )"
      @query.create_spotlight_query(filter_query,string_query)
    end.equals "kMDItemContentTypeTree == 'public.audio' && kMDItemAlbum == 'test'wc && ( kMDItemAuthors == 'holy'wc )"
    
  end

  context "parse method" do
    context "with no query args" do
      setup { @query = Dhun::Query.new }
      should("return false") { @query.parse! }.equals false
    end
  end

  context "is_valid? method" do
    setup { @query.is_valid = false }
    should("return false") { @query.is_valid? }.equals false
  end

  context "is_filter? method" do
    context "with album:test" do
      should("return true") { @query }
    end

    context "with meowmix" do
      should("return false") { @query.is_filter?("meowmix") }.equals false
    end
  end

end
