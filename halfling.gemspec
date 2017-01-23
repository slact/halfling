# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'halfling/version'

Gem::Specification.new do |spec|
  spec.name          = "halfling"
  spec.version       = Halfling::VERSION
  spec.authors       = ["Leo P."]
  spec.email         = ["junk@slact.net"]

  spec.summary       = %q{Halfling - a Hobbit with some Railsy structure}
  spec.description   = %q{Use hobbit with some template niceties and other conveniences.}
  spec.homepage      = "https://github.com/slact/halfling"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  dependencies = [
    [:runtime, "hobbit"],
    [:runtime, "hobbit-contrib"],
    [:runtime, "i18n"],
    [:runtime, 'rack-protection'],
    [:runtime, 'sprockets'],
    [:runtime, 'tilt'],
    [:runtime, 'thin'],    
    
    [:development, "bundler"],
    [:development, "rake"],
    [:development, "pry"]
  ]

  dependencies.each do |type, name, version|
    if spec.respond_to?("add_#{type}_dependency")
      spec.send("add_#{type}_dependency", name, version)
    else
      spec.add_dependency(name, version)
    end
  end
  
end
