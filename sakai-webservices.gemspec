# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sakai-webservices/version"

Gem::Specification.new do |s|
  s.name        = "sakai-webservices"
  s.version     = Sakai::WebServices::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jez Cope"]
  s.email       = ["J.Cope@bath.ac.uk"]
  s.homepage    = "http://people.bath.ac.uk/jc619/sakai-webservices-gem"
  s.summary     = %q{Access Sakai web services from Ruby.}
  s.description = %q{Access Sakai web services from Ruby.}

  s.rubyforge_project = "sakai-webservices"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('savon', '>= 0.9', '< 0.10')
  s.add_dependency('nokogiri', '>= 1.4.4')
end
