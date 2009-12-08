require 'json'
module Dhun
  class Result
    
    def initialize(result, message, options = {})
      @response = { :result => result,:message => message}
      @response.merge!(options)
    end

    def success?
      @response[:result].to_sym == :success
    end

    def error?
      @response[:result].to_sym == :error
    end

    def [](sym)
      @response[sym] || @response[sym.to_s]
    end
    
    def to_json
      @response.to_json
    end

    def self.from_json_str(resp_json)
      resp = JSON.parse(resp_json)
      Result.new(resp["result"],resp["message"],resp)
    end

  end
end
