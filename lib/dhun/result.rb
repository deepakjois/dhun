require 'json'
module Dhun
  class Result
    attr_reader :data
    
    def initialize(result, message, options = {})
      @data = { :result => result.to_sym, :message => message }.merge(options)
    end

    def success?
      @data[:result] == :success
    end

    def error?
      @data[:result] == :error
    end
    
    def [](sym)
      @data[sym.to_sym] || @data[sym.to_s]
    end
    
    def to_json
      @data.to_json
    end

    def self.from_json_str(resp_json)
      resp = JSON.parse(resp_json)
      Result.new resp.delete('result'), resp.delete('message'), resp
    end

  end
end
