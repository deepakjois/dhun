require 'socket'
require 'json'
module Dhun
  module Client

    def send_message(message,socket)
      response = nil
      UNIXSocket.open(socket) do |unix|
        unix.puts message
        response = unix.read
      end
      response
    end

    def is_server?(socket)
      begin
        UNIXSocket.open(socket) { |socket| }
        return true
      rescue StandardError
        return false
      end
    end
    
  end
end
