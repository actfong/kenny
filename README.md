# A2bLogging

The purpose of this gem is to make Rails logging great again. As a first step,
we format the logs properly. In the future this gem will replace
[lograge](https://github.com/roidrage/lograge) so we can add more information to
the request logs. It will also be the place to add custom Loggers that we might
need in the future.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'a2b_logging'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install a2b_logging

## Usage

To enable the formatter, put the following inside `production.rb`

  config.after_initialize do
    Rails.logger.formatter = A2bLogging::Formatter.new
  end

It needs to be run after_initialize done to get all the magic done that happens in
[bootstrap.rb](https://github.com/rails/rails/blob/4-2-stable/railties/lib/rails/application/bootstrap.rb)
