# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "resque-pagerduty"
  s.version     = "0.0.1"
  s.authors     = ["Maeve Revels"]
  s.email       = ["maeve.revels@g5platform.com"]
  s.homepage    = "http://github.com/maeve/resque-pagerduty"
  s.summary     = "A Resque failure backend for Pagerduty"
  s.description = <<-HERE
  resque-pagerduty provides a Resque failure backend that triggers a Pagerduty
  incident when an exception is raised by a job.
  HERE

  s.rubyforge_project = "resque-pagerduty"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('resque', '~>1.7')
  s.add_dependency('redphone', '~>0.0.6')

  s.add_development_dependency('rspec', '~>2.11')
  s.add_development_dependency('webmock', '~>1.7')

  s.add_development_dependency('yard', '~>0.8')
  s.add_development_dependency('redcarpet')
end
