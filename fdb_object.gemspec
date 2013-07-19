# -*- encoding: utf-8 -*-
# Author: peter@centzy.com (Peter Edge)

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "fdb_object/version"

Gem::Specification.new do |gem|
  gem.name          = "fdb_object"
  gem.version       = FDBObject::GEM_VERSION
  gem.authors       = ["Peter Edge"]
  gem.email         = ["peter@centzy.com"]
  gem.summary       = %{FoundationDB Object Layer}
  gem.description   = %{FoundationDB Object Layer for Ruby}
  gem.homepage      = "https://github.com/centzy/fdb_object"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  #gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  #gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "fdb"
  gem.add_dependency "multi_json"

  #gem.add_development_dependency "rspec"
  #gem.add_development_dependency "simplecov"
end
