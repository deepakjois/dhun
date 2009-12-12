require 'dhun_ext'
require 'erb'
module Dhun
  class Query

    MD_ITEMS = [:kMDItemAlbum, :kMDItemAuthors, :kMDItemComposer, :kMDItemDisplayName, :kMDItemFSName, :kMDItemTitle, :kMDItemMusicalGenre]
    MAPPINGS = { "file" => :kMDItemFSName, "album" => :kMDItemAlbum, "artist" => :kMDItemAuthors, "title" => :kMDItemTitle, "genre" => :kMDItemMusicalGenre }

    attr_reader :spotlight_query

    def initialize(args)
      @query_args = args
      parse
    end

    def parse
      return if @query_args.empty?
      filters = []
      strings = []

      @query_args.each do |arg|
        # Check if it is a filter
        if filter?(arg)
          filters.push(arg)
        else
          strings.push(arg)
        end
      end

      mappings = MD_ITEMS.clone
      fq = filters.collect do |f|
             fltr,query = *(f.split(":"))
             md_item = MAPPINGS[fltr]
             mappings.delete md_item
             "#{md_item} == '#{query.strip}'wc"
           end.join(" && ")


      template = ERB.new(mappings.collect { |key| "#{key} == '<%= keyword %>'wc" }.join(" || "))
      sq = strings.collect { |keyword|  "(" + template.result(binding) + ")"  }.join(" && ")

      @spotlight_query = ["kMDItemContentTypeTree == 'public.audio'", fq, sq].select { |s| s.length > 0 }.join(" && ")
      Logger.instance.debug @spotlight_query
      @is_valid = true
    end

    def is_valid?
      @is_valid
    end

    def filter?(str)
      return false unless str.index ":"
      a,b = *(str.split(":"))
      # Check if filter is valid
      return MAPPINGS.keys.member?(a)
    end

    # Use extension to query spotlight
    def execute_spotlight_query
      return DhunExt.query_spotlight(@spotlight_query)
    end
  end
end
