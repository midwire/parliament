lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parliament/version'

Gem::Specification.new do |spec|
  spec.name          = 'parliament'
  spec.version       = Parliament::VERSION
  spec.authors       = ['Colin Rymer', 'Mike Blackburn']
  spec.email         = ['colin.rymer@gmail.com', '87a1779b@opayq.com']
  spec.summary       = 'A Rack app for automatically merging pull request when conditions are met.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/primedia/parliament'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'github-markdown'
  spec.add_dependency 'netrc'
  spec.add_dependency 'octokit'
  spec.add_dependency 'rack'

  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'pry-nav'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'racksh'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
end
