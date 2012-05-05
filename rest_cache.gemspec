# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rest_cache/version"

Gem::Specification.new do |s|
  s.name        = "rest_cache"
  s.version     = RestCache::VERSION
  s.authors     = ["Dave Barbalato"]
  s.email       = ["dbarbalato@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Request caching for Rack-based web applications.}
  s.description = %q{RestCache is Rack middleware that relies on HTTP verbs to cache requests to your server application. Every GET request will be cached according to your initialization parameters (see example for more information), and conversely, every PUT/POST/DELETE request will clear your cache to ensure that updates are always reflected. RestCache is designed to be a lightweight, simple, yet effective tool to enhance the performance of your application. }

  s.rubyforge_project = "RestCache"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
	s.add_development_dependency "rack"
end
