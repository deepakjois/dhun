require 'optparse'

module Dhun

  # Heavily lifted from Thin codebase
  class Runner
    COMMANDS = %w(start stop)
    
    # Parsed options
    attr_accessor :options
    
    # Name of the command to be runned.
    attr_accessor :command
    
    # Arguments to be passed to the command.
    attr_accessor :arguments
    
    # Return all available commands
    def self.commands
      commands  = COMMANDS
      commands
    end

    def initialize(argv)
      @argv = argv
      # Default options values
      @options = {}      
      parse!
    end

    def parser
      # NOTE: If you add an option here make sure the key in the +options+ hash is the
      # same as the name of the command line option.
      # +option+ keys are used to build the command line to launch other processes,
      # see <tt>lib/dhun/command.rb</tt>.
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: dhun  #{self.class.commands.join('|')}"
        opts.on_tail("-h", "--help", "Show this message")  { puts opts; exit }
      end
    end
    
    def parse!
      parser.parse! @argv
      @command   = @argv.shift
      @arguments = @argv
    end

    # Parse the current shell arguments and run the command.
    # Exits on error.
    def run!
      if self.class.commands.include?(@command)
        run_command
      elsif @command.nil?
        puts "Command required"
        puts @parser
        exit 1  
      else
        abort "Unknown command: #{@command}. Use one of #{self.class.commands.join(', ')}"
      end
    end

    def run_command
      puts "Run command #{@command}"
    end
  end
end
