# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'peripatetic/version'

Gem::Specification.new do |gem|
  gem.name          = "peripatetic"
  gem.version       = Peripatetic::VERSION
  gem.authors       = ["Scott Smith"]
  gem.homepage      = 'http://rake.rubyforge.org'

  gem.email         = ["scottsmit@gmail.com"]
  gem.description   = "Drop in Location"
  gem.summary       = "Any Model may has_many or has_one location and drop it in the form in a nested set"
  gem.homepage      = "https://github.com/davingee/Peripatetic"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})

  gem.add_dependency "geocoder"
  gem.add_development_dependency "cucumber"
  gem.add_development_dependency "rspec"

  gem.require_paths = ["lib"]
end
