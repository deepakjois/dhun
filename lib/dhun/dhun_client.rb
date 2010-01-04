require 'socket'
require 'json'
module Dhun
  class DhunClient
    attr_accessor :options

    def initialize(options)
      @options = options
      raise "Dhun server is not running" unless DhunClient.is_dhun_server_running?(options[:socket])
    end

    def send(message)
      u = UNIXSocket.new(options[:socket])
      u.puts message
      resp = u.read
      u.close
      return resp
    end

    def self.is_dhun_server_running?(socket)
      begin
        UNIXSocket.new(socket)
        return true
      rescue StandardError => ex
        return false
      end
    end
  end
end
