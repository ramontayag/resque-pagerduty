# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "resque_pagerduty/version"

Gem::Specification.new do |s|
  s.name        = "resque_pagerduty"
  s.version     = ResquePagerduty::VERSION
  s.authors     = ["maeve"]
  s.email       = ["maeve.revels@g5platform.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "resque_pagerduty"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
