require 'rubygems'
require 'daemons'

dhun_server = File.dirname(__FILE__)+"/dhun_server.rb"
Daemons.run(dhun_server,
  :dir_mode => :normal,
  :dir => '/tmp/'
)
