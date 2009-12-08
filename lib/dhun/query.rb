require 'dhun_ext'
module Dhun
  class Query

    MD_ITEMS = [:kMDItemAlbum, :kMDItemAuthors, :kMDItemComposer, :kMDItemDisplayName, :kMDItemFSName, :kMDItemTitle, :kMDItemMusicalGenre]
    attr_reader :query_string
    attr_reader :spotlight_query

    def initialize(query_string)
      @query_string = query_string
      parse
    end

    def parse
      str = MD_ITEMS.collect do |item|
             "#{item.to_s} == '#{@query_string}'wc" 
            end.join(" || ")

      @spotlight_query = "kMDItemContentTypeTree == 'public.audio' && (#{str})"
      puts @spotlight_query
      @is_valid = true
    end

    def is_valid?
      @is_valid
    end

    # Use extension to query spotlight
    def execute_spotlight_query
      return DhunExt.query_spotlight(@spotlight_query)
    end

    def get_metadata_item(field)
      case field
        when "album"    then :kMDItemAlbum
        when "artist"   then :kMDItemAuthors
        when "composer" then :kMDItemComposer
        when "title"    then :kMDItemTitle
        when "genre"    then :kMDItemMusicalGenre
        else "Unknown"
      end
    end
  end
end
