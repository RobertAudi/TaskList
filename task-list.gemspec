# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "task-list/version"

Gem::Specification.new do |s|
  s.name        = "task-list"
  s.version     = TaskList::VERSION
  s.authors     = ["Aziz Light"]
  s.email       = ["aziz@azizlight.me"]
  s.homepage    = ""
  s.summary     = %q{Code tasks parser and lister}
  s.description = %q{TaskList parses source code to find code tags and list them in a terminal. See README.md for more info.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
