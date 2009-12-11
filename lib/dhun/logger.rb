require 'singleton'
module Dhun
  class Logger
    include Singleton
    
    attr_accessor :log_level,:file
    
    def initialize
      @file = STDOUT
    end

    def file=(f)
      @file = File.open(f,'w')
    end

    def log(msg)
      @file.puts "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} #{msg}" unless self.log_level == :silent
      @file.flush
    end

    def debug(msg)
      log(msg) if self.log_level == :debug
    end
  end
end
