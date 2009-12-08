require 'json'
module Dhun
  class Command
    attr_reader :commands, :arguments
    
    def initialize(command,arguments)
      @command = command
      @arguments = arguments
    end
    
    def to_json
      { "command" => @command, "arguments" => @arguments }.to_json
    end
  end
end
