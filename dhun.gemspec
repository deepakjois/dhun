Gem::Specification.new do |s|
  s.name = 'dhun'
  s.version = '0.6.5'
  s.summary = "Minimalist music player for OS X"
  s.date = '2010-01-22'
  s.email = 'deepak.jois@gmail.com'
  s.homepage = 'http://github.com/deepakjois/dhun'
  s.has_rdoc = false
  s.add_development_dependency('riot', '>=0.10.11')
  s.add_development_dependency('rr', '>=0.10.5')
  s.add_dependency('eventmachine', '>=0.12.10')
  s.add_dependency('json_pure', '>=1.2.0')
  s.add_dependency('daemons', '>=1.0.10')
  s.add_dependency('thor', '>=0.12.0')
  s.add_dependency('ruby-mp3info','>=0.6.13')
  s.add_dependency('visionmedia-growl','>=1.0.3')
  s.authors = ["Deepak Jois"]
  # = MANIFEST =
  s.files = %w[
    CONTRIBUTORS
    FIX.md
    LICENSE.txt
    README.md
    Rakefile
    TODO.md
    bin/dhun
    dhun.gemspec
    ext/Makefile
    ext/dhun.h
    ext/dhun_ext.c
    ext/extconf.rb
    ext/player.c
    ext/query.c
    lib/dhun.rb
    lib/dhun/client.rb
    lib/dhun/dhun_server.rb
    lib/dhun/handler.rb
    lib/dhun/logger.rb
    lib/dhun/player.rb
    lib/dhun/query.rb
    lib/dhun/result.rb
    lib/dhun/runner.rb
    lib/dhun/server.rb
  ]
  # = MANIFEST =
  s.extensions = ["ext/extconf.rb"]
  s.executables = ["dhun"]
  s.require_paths = ["lib"]
  s.rubyforge_project = 'dhun'
end
