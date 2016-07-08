# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "a2b_logging"
  spec.version       = "0.1.0"
  spec.authors       = ["Mathias Rüdiger"]
  spec.email         = ["mathias.ruediger@fromatob.com"]

  spec.summary       = "Tame Rails logs, add timestamps and make them useable"
  spec.description   = "Tame Rails logs, add timestamps and make them useable. To be used with Logstash"

  spec.licenses       = %w(MIT)

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = Dir["lib/a2b_logging.rb",
                           "lib/railtie.rb", 
                           "lib/a2b_logging/**/*.rb", 
                           "Gemfile", 
                           "LICENSE", 
                           "Rakefile", 
                           "README.md"]
  spec.homepage      = "http://www.fromatob.com"
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10.3"

  spec.add_runtime_dependency 'actionpack', '>= 4', '< 5.1'
  spec.add_runtime_dependency "activesupport", "~> 4.2"
  spec.add_runtime_dependency "logstash-event", "1.2.02"
end
