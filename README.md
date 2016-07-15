# Kenny
Inspired by [lograge](https://github.com/roidrage/lograge), but without the rage. And logs are optional.

Lograge does a great job in suppressing Rails' log output, it does so by:
- overriding Rails' default behaviour for instrumentations/subscriptions
- being very opinionated, hence removing a lot of data from your log.

As a result, even though Lograge is great for cleaning your production.log, it is neither meant for collecting metrics nor great for plugging into any instrumentation event that you want.

Kenny attempts to leave implementations to the user and provide a more modular way to monitor instrumentation events.
It allows the user to decide:
- which instrumentations to monitor
- what to do when the specified instrumentation-event occurs
- where to log the data to (or no logging to file at all)
- whether or not to unsubscribe from Rails' default instrumentations (although not recommended)

Apart from that, it was also created with the idea of keeping all subscribed events in one place. So it will keep your code clean and provide a nice overview of all event-triggered actions.

Best to be explained with an example.

## Installation

Gemfile:

```ruby
gem 'kenny'
```

And then execute:

    $ bundle

Or command line:

    $ gem install kenny

## Usage
  Kenny can be configured through an initializer (`config/initializers/kenny.rb`) or within the configuration file of your environment `development|test|staging|production.rb`.
  This depends on whether you want to same or different behaviour accross environments.

  If you do configure Kenny through an initializer, then it would give you the advantage of keeping all your instrumentation configurations in one place.

  Here is an example, its details will be explained in the following paragraphs.

  ```ruby
  # Example
  MyApp::Application.configure do
    # Define a logger-instance with formatter to be used later
    request_logger = ActiveSupport::Logger.new( File.join(Rails.root, "log", "process_action.log") )
    log_stash_formatter = Kenny::Formatters::LogStashFormatter.new
    request_logger.formatter = log_stash_formatter

    config.kenny.unsubscribe_rails_defaults = false
    config.kenny.suppress_rack_logger = true
    config.kenny.instrumentations = [
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

  end

  ```


### `kenny.instrumentations` configuration
  Before proceeding, have a look at [Active Support Instrumentation](http://edgeguides.rubyonrails.org/active_support_instrumentation.html) and [LogSubscriber](http://api.rubyonrails.org/classes/ActiveSupport/LogSubscriber.html)

  The `kenny.instrumentations` configuration takes an array of hashes. Each hash represents a Rails instrumentation-event that you want to subscribe to.

  Each of these hashes requires a `:name` (name of instrumentation event), a `:block` (what to do when that event occurs) and *optionally* a `:logger` (which logger to use in order to write these events to a file).

  In the example above, we setup Kenny to monitor two instrumentation events, `process_action.action_controller` and `sql.active_record`.

  For every instrumentation that you want to monitor, you have to provide a `:name` and a `:block`. `:logger` is optional.

  Behind the scenes, it defines an anonymous class (< ActiveSupport::LogSubscriber), for each of the specified instrumentation.

  The first one gets method `def process_action` defined and `def logger` *redefined*.

  The body of `def process_action` is the `:block` that has been supplied to the configuration.
  Hence `:block` must be a Lambda or a Proc.
  (Lambda will raise errors with wrong number of arguments, Proc won't)

  The `def logger` method (in ActiveSupport::LogSubscriber) gets overridden and will return the logger-instance that you have provided to the configuration. (In this case, its the `request_logger` that you have defined at the top of your config).

  This class is then attached to :action_controller, by looking up the event-name 'process_action.action_controller'

  The idea of redefining `def logger` may sound a bit scary, but this is necessary to keep events from
  different instrumentation channels on different log files. If `:logger` option is not provided, then that LogSubscriber class will use the default Rails logger (and hence writing to your production.log etc)

  The second LogSubscriber class will have method `def start_processing` defined and the method body is again what has been supplied in the :block configuration.

  The difference is that `:logger` has not been provided, hence it won't override the logger method for this LogSubscriber. In Rails, this means it will fall back to the default `Rails.logger`.
  Mind you that even though a LogSubscriber has access to a logger, it does not mean you have to use it! There is nothing wrong with subscribing to an event and not log its data to file at all! There are other things you could do with this data.
  At the end, this class gets attached to :active_record, by looking up the event-name 'sql.active_record'

#### Be careful with variable scopes and lambdas
  Since lambda's are used to define method bodies, be careful with context of variables.
  Take the example below:

  ``` Ruby
  # Somewhere above the instrumentation configurations
  logger = ActiveSupport::Logger.new( File.join(Rails.root, "log", "process_action.log") )

  # Then within the instrumentation configuration
  config.kenny.instrumentations = [
    { name: 'sql.active_record',
      block: lambda do |event|
        data = event.payload
        logger.info("#{event.name}: #{data}")
      end
    }
  ]
  ```

  You might think that since no `:logger` option has been provided, for 'sql.active_record' events, the default logger will be used..... But that is not true.
  Since `logger` is within scope at the time when the lambda was defined, this instance of ActiveSupport::Logger will be used to invoke `#info` when 'sql.active_record' occurs. So just avoid creating a local variables that have the same name as variables in your block.


### `kenny.unsubscribe_rails_defaults` configuration
  Kenny can also used to unsubscribe all Rails LogSubscribers from their subscribed instrumentation-events.
  You can do that by setting `:unsubscribe_rails_defaults` to true:

  ``` Ruby
  config.kenny.unsubscribe_rails_defaults = true
  config.kenny.instrumentations = [{
      # your stuff
    }]
  }
  ```

  By doing so, your `development|test|staging|production.log` will not have any of the default log messages. This is not an approach I would recommend, unless you are desparate to have all messages from your specified instrumentation-events all logged into one `development|test|staging|production.log`.


### `kenny.suppress_rack_logger` configuration
  By default, your rails app logs messages like these to your environment's log:

  ```
  Started GET "/my_path" for 10.0.2.2 at 2016-07-12 10:06:48 +0000
  Started GET "/assets/sh/my_styles.css?body=1" for 10.0.2.2 at 2016-07-12 10:06:49 +0000
  ```

  You can suppress these messages by setting kenny.suppress_rack_logger to true.
  This setting will not have any effects on the log files that you create separately with the `:logger` option within your specified instrumentation.

## Open-to-Implementation approach
  As you might have seen from the example, the `:block` allows you to define your own implementation.
  My idea behind writing this gem, is to free up the user from the tedious task of defining LogSubscriber classes and to allow the user to define whatever (s)he wants to do with the event data, be it something like:

  ```Ruby
    config.kenny.instrumentations = [
      { name: 'process_action.action_controller',
        block: lambda do |event|
          data = MyDataBuilder.build(event)
           # Use Fluent to send data to another server
          Fluent::Logger::FluentLogger.open(nil, :host=>MY_SERVER, :port=>24224)
          Fluent::Logger.post('web_requests', data)
        end
      },
      { name: 'sql.active_record',
        block: lambda do |event|
          data = MyDataBuilder.build(event)
          # Do something asynchronously, maybe send to an external service
          Something.async.process_and_forward(data)
        end
      }
    ]
  ```

  Again, there is no requirement for you to write messages to log files. It is all up to you.

## Formatters
  Apart from subscribing to instrumentation-events and logging, Kenny also provides formatters, which you can attach to a logger.

  Currently it only comes with a LogStashFormatter, but feel free to add more Formatters to make this project great.
