# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "typed_fields/version"

Gem::Specification.new do |s|
  s.name        = "typed_fields"
  s.version     = TypedFields::VERSION
  s.authors     = ["Victor Savkin"]
  s.email       = ["vic.savkin@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{It types all your fields. Adds methods to convert a hash of strings into specified types.}
  s.description = %q{}

  s.rubyforge_project = "typed_fields"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end
