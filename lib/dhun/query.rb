require 'dhun_ext'

module Dhun
  class Query

    MD_ITEMS = [
      :kMDItemAlbum,
      :kMDItemAuthors,
      :kMDItemComposer,
      :kMDItemDisplayName,
      :kMDItemFSName,
      :kMDItemTitle,
      :kMDItemMusicalGenre
    ]

    MAPPINGS = {
      :file => :kMDItemFSName,
      :album => :kMDItemAlbum,
      :artist => :kMDItemAuthors,
      :title => :kMDItemTitle,
      :genre => :kMDItemMusicalGenre,
      :composer => :kMDItemComposer,
      :display => :kMDItemDisplayName
    }

    attr_accessor :spotlight_query,:is_valid,:logger,:query_search,:query_fields

    def initialize(search=nil,fields={})
      @logger = Dhun::Logger.instance
      @query_search = search
      @query_fields = fields
      @is_valid = parse!
    end

    # parses all search terms and stores query
    # return false if both are empty.
    def parse!
      return false if @query_search.nil? and @query_fields.empty?

      mappings = MD_ITEMS.clone   #instantiate mappings to be picked off by query methods
      #create the queries
      filter_query = create_filter_query(@query_fields,mappings)
      string_query = create_string_query(@query_search,mappings)
      @spotlight_query = create_spotlight_query(filter_query,string_query)

      @logger.debug @spotlight_query
      return true
    end

    # create filter queries
    # { :album => 'test' } => "kMDItemAlbum == 'test'wc"
    # ADDITIONALLY, throws out any non matching filters
    # { :album => 'test', :booger => 'one' } => "kMDItemAlbum == 'test'wc"
    def create_filter_query(filters,mappings)
      filters.collect do |field,value|
        next unless MAPPINGS[field.to_sym] # makes sure that field is to sym, or funky stuff happens
        md_item = MAPPINGS[field.to_sym]
        mappings.delete md_item
        "#{md_item} == '#{value}'wc && "
      end.join.chomp(" && ")
    end

    # create string queries
    # this sets string to all fields not already matched
    # by create_filter_query
    # 'test' => "( kMDItemTitle == 'holy'wc || kMDItemMusicalGenre == 'holy'wc )"
    # if kMDItemTitle and kMDItemMusicalGenre are the only fields left open.
    # returns "" if given nil
    # if given multiple strings:
    # 'holy','test' =>
    # ( kMDItemTitle == 'holy'wc || kMDItemMusicalGenre == 'holy'wc ) && ( kMDItemTitle == 'test'wc || kMDItemMusicalGenre == 'test'wc )
    def create_string_query(strings,mappings)
      return "" unless strings
      strings.collect do |keyword|
        query = mappings.collect { |key| "%s == '%s'wc" % [key,keyword] }.join(" || ")
        "( #{query} )"
      end.join(" && ")
    end

    # create spotlight queries
    # with {:album => 'test'},"" =>
    # "kMDItemContentTypeTree == 'public.audio' && kMDItemAlbum == 'test'wc"
    def create_spotlight_query(filter_query,string_query)
      ["kMDItemContentTypeTree == 'public.audio'", filter_query, string_query].select do
        |s| s.length > 0
      end.join(" && ")
    end

    # Use extension to query spotlight
    def execute_spotlight_query
      return DhunExt.query_spotlight(@spotlight_query)
    end

    def is_valid?; @is_valid; end

  end
end
