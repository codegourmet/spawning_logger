# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |gem|
  gem.name          = "spawning-logger"
  gem.version       = SpawningLogger::VERSION
  gem.authors       = ["Markus Seeger"]
  gem.email         = ["mail@codegourmet.de"]
  gem.description   = "A logger that can spawn other loggers"
  gem.summary       = ""
  gem.homepage      = "https://github.com/codegourmet/spawning_logger"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake",  "~> 10.1"
  gem.add_development_dependency "guard-minitest"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "minitest-reporters"
  gem.add_development_dependency "simplecov"
end
