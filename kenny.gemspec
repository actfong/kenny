# coding: utf-8
Gem::Specification.new do |spec|
  spec.name = 'kenny'
  spec.version = '0.1.4'
  spec.authors = ['Mathias Rüdiger', 'Alex Fong']
  spec.email = ['mathias.ruediger@fromatob.com', 'alex.fong@fromatob.com']

  spec.summary = 'Monitor and act upon Rails instrumentation events.'
  spec.description = 'One-stop destination for defining you actions' \
                     'when specific Rails instrumentations occur'

  spec.licenses = %w(MIT)

  spec.files = Dir['lib/kenny.rb',
                   'lib/railtie.rb',
                   'lib/kenny/**/*.rb',
                   'Gemfile',
                   'LICENSE',
                   'Rakefile',
                   'README.md']
  spec.homepage = 'https://github.com/fromAtoB/kenny'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rubocop', '~> 0.41'
  spec.add_development_dependency 'appraisal', '~> 2.2'

  spec.add_runtime_dependency 'actionpack', '~> 4.2'
  spec.add_runtime_dependency 'activerecord', '~> 4.2'
  spec.add_runtime_dependency 'actionmailer', '~> 4.2'
  spec.add_runtime_dependency 'activesupport', '~> 4.2'
  spec.add_runtime_dependency 'railties',      '~> 4.2'
  spec.add_runtime_dependency 'logstash-event', '~> 1.2.02'
end
