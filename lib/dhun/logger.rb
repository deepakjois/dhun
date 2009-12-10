require 'singleton'
module Dhun
  class Logger
    include Singleton
    
    attr_accessor :log_level
    
    def log(msg)
      puts "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} #{msg}" unless self.log_level == :silent
    end

    def debug(msg)
      log(msg) if self.log_level == :debug
    end
  end
end
