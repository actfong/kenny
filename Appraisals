%w(4.2 5.0 5.1 5.2).each do |version|
  appraise "rails-#{version}" do
    gem 'actionpack',    "~> #{version}.0"
    gem 'activerecord',  "~> #{version}.0"
    gem 'actionmailer',  "~> #{version}.0"
    gem 'activesupport', "~> #{version}.0"
    gem 'railties',      "~> #{version}.0"
  end
end
