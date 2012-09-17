# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "resque_pagerduty/version"

Gem::Specification.new do |s|
  s.name        = "resque_pagerduty"
  s.version     = ResquePagerduty::VERSION
  s.authors     = ["maeve"]
  s.email       = ["maeve.revels@g5platform.com"]
  s.homepage    = ""
  s.summary     = "A Resque failure backend for PagerDuty"
  s.description = "resque_pagerduty provides a Resque failure backend that triggers a Pagerduty incident when an exception is raised by a job."

  s.rubyforge_project = "resque_pagerduty"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('resque', '~>1.7')
  s.add_dependency('json')

  s.add_development_dependency('rspec', '~>2.11')
  s.add_development_dependency('webmock', '~>1.7')
  s.add_development_dependency('fakefs', '~>0.4')

  s.add_development_dependency('yard', '~>0.8')
  s.add_development_dependency('redcarpet')
end
