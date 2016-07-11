# A2bLogging
Inspired by [lograge](https://github.com/roidrage/lograge), but without the rage.

Lograge does a great job in suppressing Rails' log output, but it does so by overriding Rails' default behaviour for instrumentations/subscriptions, as well as having a say on the content of the log messages.

A2bLogging attempts to leave implementations to the user and provide a more modular way to monitor instrumentation events.
It allows the user to decide: 
- which instrumentations to monitor
- what to do when the specified instrumentation-event occurs
- where to log the data to (or no logging to file at all, it's all up to you)
- whether or not to remove Rails' default instrumentation monitoring (although not recommended)

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
  A2bLogging can be configured through an initializer (`config/initializers/a2b_logging.rb`) or within the configuration file of your environment `development|test|staging|production.rb`. 
  This depends on whether you want to same or different behaviour accross environments.

  ```ruby
MyApp::Application.configure do
  request_logger = ActiveSupport::Logger.new( File.join(Rails.root, "log", "process_action.log") )
  log_stash_formatter = A2bLogging::Formatters::LogStashFormatter.new
  request_logger.formatter = log_stash_formatter

  config.a2b_logging = {
    instrumentations:[ 
      { name: 'process_action.action_controller',
        block: lambda do |event|
          data = MyDataBuilder.build(event)
          logger.info("#{event.name}: #{data}")
        end,
       logger: request_logger
      },
      { name: 'sql.active_record',
        block: lambda do |event|
          data = event.payload
          Rails.logger.info("#{event.name}: #{data}") 
        end
      }
    ]
  }
end

  ```

### Instrumentations Config
  In the example above, we setup A2bLogging to monitor two instrumentation events, `process_action.action_controller` and `sql.active_record`.

  For every instrumentation that you want to monitor, you have to provide a `:name` and a `:block`. `:logger` is optional

  Behind the scenes, it defines two anonymous classes, that inherit from ActiveSupport::LogSubscriber

  The first one gets method `def process_action` defined and `def logger` *redefined*.

  The body of `def process_action` is the `:block` that has been supplied to the configuration. 
  Hence `:block` must be a lambda or a Proc. 
  (Lambda will raise errors with wrong number of arguments, Proc won't)
  
  The `def logger` method gets overridden and will return the logger-instance that you have provided to the configuration. (in this case, its the `request_logger` that you have defined at the top of your config). 

  This class is then attached to :action_controller

  The idea of redefining `def logger` may sound a bit scary, but this is necessary to keep events from 
  different instrumentation channels on different log files. If `:logger` option is not provided, then that LogSubscriber class will use the default Rails logger (and hence writing to your production.log etc)

  The second LogSubscriber class has method `start_processing` defined and the method body is again what has been supplied in the :block configuration. 

  The difference is that `:logger` has not been provided, hence it won't override the logger method for this LogSubscriber. In Rails, this means it will fall back to the default `Rails.logger`.


### Be careful with variable scopes and lambdas
  Since lambda's are used to define method bodies, be careful with context of variables.
  Take the example below:

  ``` Ruby
  # Somewhere above the instrumentation configurations
  logger = ActiveSupport::Logger.new( File.join(Rails.root, "log", "process_action.log") )

  # Then within the instrumentation configuration
  config.a2b_logging = {
    instrumentations:[
    { name: 'sql.active_record',
      block: lambda do |event|
        data = event.payload
        logger.info("#{event.name}: #{data}") 
      end
    }
  ``` 

  You might think that since no `:logger` option has been provided, for 'sql.active_record' events, the default logger will be used..... But that is not true. 
  Since `logger` is within scope at the time when the lambda was defined, this instance of ActiveSupport::Logger will be used to invoke `#info` when 'sql.active_record' occurs.

## Unsubscribe Rails' default LogSubscribers from their subscribed instrumentation-events
  Apart from defining your actions when an instrumentation-event occurs and where to log the data to, you can also use A2bLogging to unsubscribe all Rails LogSubscribers from their subscribed instrumentation-events.

  ``` Ruby
  config.a2b_logging = {
    unsubscribe_rails_defaults: true,
    instrumentations:[{
      # your stuff
    }]
  }
  ```

  By doing so, your `development|test|staging|production.log` will not have any of the default log messages. This is not an approach I would recommend, unless you are desparate to have all messages from your specified instrumentation-events all logged into one `development|test|staging|production.log`.

## Open-to-Implementation approach
  As you might have seen from the example, the `:block` allows you to define your own implementation.
  My idea behind writing this gem, is to free up the user from the tedious task of defining LogSubscriber classes and to allow the user define whatever (s)he wants to do with the event data, be it something like:

  ```Ruby
    config.a2b_logging = {
      instrumentations:[
        { name: 'process_action.action_controller',
          block: lambda do |event|
            data = MyDataBuilder.build(event)
            Fluent::Logger.post(FLUENTD_APP_EVENTS_LABEL, data) # Use Fluent to send data to another server
          end 
        },
        { name: 'sql.active_record',
          block: lambda do |event|
            data = MyDataBuilder.build(event)
            Something.async.processdata(data) # Do someting asynchronously
          end 
        }
      ]
    }
  ```

  And again, there is no requirement for you to write messages to log files. It is all up to you.
