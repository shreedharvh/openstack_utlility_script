# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ostack_util/version'

Gem::Specification.new do |spec|
  spec.name          = 'ostack_util'
  spec.version       = OstackUtil::VERSION
  spec.authors       = ['cloudsquad']
  spec.email         = ['amit.bhosale@cerner.com']

  spec.summary       = 'Monitoring IP Availability in an OpenStack Cluster'
  spec.description   = 'Monitoring IP Availability in an OpenStack Cluster'
  spec.homepage      = 'https://github.cerner.com/ETS/ostack_util'
  spec.license       = "MIT"

   # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'http://repo.release.cerner.corp/internal/rubygems'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = 'ostack_util'
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'thor', '~> 0.19'
  spec.add_runtime_dependency 'mysql', '~> 2.9'
  spec.add_runtime_dependency 'sequel', '~> 4.41'
  spec.add_runtime_dependency 'ipaddress', '~> 0.8'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
