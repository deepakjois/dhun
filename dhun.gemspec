Gem::Specification.new do |s|
  s.name = 'dhun'
  s.version = '0.5.1'
  s.summary = "Minimalist music for OS X"
  s.date = '2009-12-08'
  s.email = 'deepak.jois@gmail.com'
  s.homepage = 'http://github.com/deepakjois/dhun'
  s.has_rdoc = false
  s.authors = ["Deepak Jois"]
  # = MANIFEST =
  s.files = %w[
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
    lib/dhun/command.rb
    lib/dhun/controller.rb
    lib/dhun/dhun_client.rb
    lib/dhun/dhun_server.rb
    lib/dhun/handler.rb
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
