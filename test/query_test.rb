require File.expand_path("test_helper", File.dirname(__FILE__))

context "the Dhun::Query" do
  setup { @query = Dhun::Query.new('regular',{:artist => 'bobby'}) }

  context "on initialize" do
    asserts("assigns @query_fields").assigns(:query_fields)
    asserts("assigns @query_search").assigns(:query_search)
    asserts("assigns @is_valid").assigns(:is_valid)
    should("be valid") { @query.is_valid? }.equals true
  end
  
    # # These test cases only apply to a specific system(mine)
    # # and where a shortcut way to test the underlying DhunExt.query_spotlight method
    # context "execute_spotlight_query method(isolated cases, ignore)" do
    #   
    #   context "with string query" do
    #     setup { @query = Dhun::Query.new('deadmau5',{}) }
    #     should("show 21 results") { @query.execute_spotlight_query.size }.equals 21
    #   end
    #   
    #   context "with artist field" do
    #     setup { @query = Dhun::Query.new(nil,{:artist => 'deadmau5'}) }
    #     should("show 21 results") { @query.execute_spotlight_query.size }.equals 19
    #   end
    # end
  
  context "create_filter_query method" do

    asserts("field converted to sym") do
      @query.create_filter_query({'album' => 'test'},Dhun::Query::MD_ITEMS.clone)
    end.equals "kMDItemAlbum == 'test'wc"

    context "with two queries" do
      setup do
        q = {:genre => 'techno', :album => 'test'}
        @query.create_filter_query(q,Dhun::Query::MD_ITEMS.clone)
      end
      should("return album query").matches(/kMDItemAlbum == 'test'wc/)
      should("contain &&").matches(/&&/)
      should("return genre query").matches(/kMDItemMusicalGenre == 'techno'wc/)
    end

    asserts("delete keys at mappings") do
      mappings = Dhun::Query::MD_ITEMS.clone
      @query.create_filter_query({:album => 'test'},mappings)
      mappings.include? :kMDItemAlbum
    end.equals false
  end

  context "create_string_query method" do
    
    should "return query" do
      @query.create_string_query('test',[:kMDItemAlbum])
    end.equals "( kMDItemAlbum == 'test'wc )"
    
    should("return no query") { @query.create_string_query(nil,[:kMDItemAlbum]) }.equals ''

    context "with two strings" do
      setup { @query.create_string_query(['holy','cannoli'],[:kMDItemAlbum]) }
      should("return first query").matches(/kMDItemAlbum == 'holy'wc/)
      should("contain &&").matches(/&&/)
      should("return second query").matches(/kMDItemAlbum == 'cannoli'wc/)
    end
    
    context "with two open fields" do
      setup { @query.create_string_query(['holy'],[:kMDItemAlbum, :kMDItemAuthors]) }
      should("return query").matches(/\( kMDItemAlbum == 'holy'wc \|\| kMDItemAuthors == 'holy'wc \)/)
    end
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
  
  context "parse! method" do
    
    should("return false with no arguments") {  Dhun::Query.new.parse! }.equals false
    should("return true with no search") { Dhun::Query.new(nil,{:artist => 'monkey'}).parse! }.equals true
    should("return true with no fields") { Dhun::Query.new('').parse! }.equals true
    
    context "with filter query" do
      setup do
        @query = Dhun::Query.new "",:album => 'test'
      end
      should "return spotlight query" do
        @query.parse!
        @query.spotlight_query
      end.equals "kMDItemContentTypeTree == 'public.audio' && kMDItemAlbum == 'test'wc"
    end
  
    context "with query args" do
      setup do
        stub(@query).create_filter_query(anything,anything) { true }
        stub(@query).create_string_query(anything,anything) { true }
        stub(@query).create_spotlight_query(anything,anything) { "spotlight query" }
        @query.parse!
      end
      asserts("assigns @spotlight_query") {@query.spotlight_query }.equals "spotlight query"
      should("return true").equals true
    end
  end
  
  context "is_valid? method" do
    setup { @query.is_valid = false }
    should("return false") { @query.is_valid? }.equals false
  end
  
end
