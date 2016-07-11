# A2bLogging
Inspired by [lograge](https://github.com/roidrage/lograge), but without the rage.

While Lograge does a great job in suppressing Rails' log output, it does override which instrumentations
to monitor and the content of the log messages.

A2bLogging is meant to be more flexible: It allows the user
- to choose which instrumentations to monitor,
- what to do when an event from that instrumentation occurs,
- where to log the data to
- and to remove Rails' default instrumentation monitoring (although not recommended)

Best to be explained with an example.

## Installation

Gemfile:

```ruby
gem 'a2b_logging'
```

And then execute:

    $ bundle

Or command line:

    $ gem install a2b_logging

## Usage
  In the configuration file of your environment `development|test|staging|production.rb`

  ```ruby
  request_logger = ActiveSupport::Logger.new( File.join( Rails.root, "log", "process_action.log") )
  log_stash_formatter = A2bLogging::Formatters::LogStashFormatter.new
  logger.formatter = log_stash_formatter

  config.a2b_logging = {
    instrumentations:[ 
      {
       name: 'process_action.action_controller',
       block: lambda do |event|
         data = event.payload
         logger.info("#{event.name}: #{data}")
       end,
       logger: request_logger
      },
      {
       name: 'start_processing.action_controller',
       block: lambda do |event|
         data = event.payload
         logger.info("#{event.name}: #{data}") # Be careful with shadowing
       end
      }
    ] 
  }
  ```

### Instrumentations Config
  In the example above, we setup A2bLogging to monitor two instrumentation events, `process_action.action_controller` and `start_processing.action_controller`.

  Behind the scenes, it defines two anonymous classes, that inherits from ActiveSupport::LogSubscriber

  The first one gets method `def process_action` defined and `def logger` *redefined*.

  The body of `def process_action` is the `:block` that has been supplied to the configuration. 
  
  The `def logger` method gets overridden and will return the logger-instance that you have provided to the configuration. (in this case, its `request_logger`)

  This class is then attached to :action_controller

  The second one has method `start_processing` defined and the method body is again what has been supplied in the :block configuration. 

  The difference is that `:logger` has not been provided, hence it won't override the logger method for this LogSubscriber. In Rails, this means it will fall back to the default `Rails.logger`.

  So in the block of 'start_processing.action_controller', the `logger` (as in logger.info) refers to the logger returned from the context of an instance of LogSubscriber. 

  Be careful with shadowing variables when providing a lambda. 
  In the example above, IF the `request_logger` was named `logger`, when the lambda get evaluated in the anonymous class, it will take the logger defined above the a2b_configs instead of the logger method in its own class!




  


