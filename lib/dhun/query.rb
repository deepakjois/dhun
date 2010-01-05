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
      "file" => :kMDItemFSName,
      "album" => :kMDItemAlbum,
      "artist" => :kMDItemAuthors,
      "title" => :kMDItemTitle,
      "genre" => :kMDItemMusicalGenre
    }

    attr_accessor :spotlight_query,:query_args,:is_valid,:logger

    def initialize(args="")
      @logger = Logger.instance
      @query_args = args
      @is_valid = parse!
    end

    def parse!
      return false if @query_args.empty?
      
      parse_filters,parse_strings = [],[]
      mappings = MD_ITEMS.clone
      
      # seperate the filter queries and regular string queries
      @query_args.each do |arg|
        is_filter?(arg) ? parse_filters.push(arg) : parse_strings.push(arg)
      end
      
      #create the queries
      filter_query = create_filter_query(parse_filters,mappings)
      string_query = create_string_query(parse_strings,mappings)
      @spotlight_query = create_spotlight_query(filter_query,string_query)

      @logger.debug @spotlight_query
      return true
    end

    # returns @is_valid
    def is_valid?; @is_valid; end

    # create filter queries
    # 'album:test' => "kMDItemAlbum == 'test'wc"
    # ADDITIONALLY, throws out any non matching filters
    # ['album:test','booger:bigone'] => "kMDItemAlbum == 'test'wc"
    def create_filter_query(filters,mappings)
      filters.collect do |f|
        fltr,query = *(f.split(':'))
        next unless MAPPINGS[fltr]
        md_item = MAPPINGS[fltr]
        mappings.delete md_item
        "#{md_item} == '#{query.strip}'wc && "
      end.join.chomp(" && ")
    end

    # create string queries
    # this sets string to all fields not already matched
    # by create_filter_query
    # 'test' => "( kMDItemTitle == 'holy'wc || kMDItemMusicalGenre == 'holy'wc )"
    # if kMDItemTitle and kMDItemMusicalGenre are the only fields left open.
    def create_string_query(strings,mappings)
      strings.collect do |keyword|
        query = mappings.collect { |key| "%s == '%s'wc" % [key,keyword] }.join(" || ")
        "( #{query} )"
      end.join(" && ")
    end

    # create spotlight queries
    def create_spotlight_query(filter_query,string_query)
      ["kMDItemContentTypeTree == 'public.audio'", filter_query, string_query].select do
        |s| s.length > 0
      end.join(" && ")
    end

    # returns false if str does not contain ':' => 'meowmix'
    # returns false if str token not included in mappings
    def is_filter?(str)
      return false unless str.index ":"
      return MAPPINGS.keys.member?(str.split(":").first)  # Check if filter is valid
    end

    # Use extension to query spotlight
    def execute_spotlight_query
      return DhunExt.query_spotlight(@spotlight_query)
    end
  end
end
