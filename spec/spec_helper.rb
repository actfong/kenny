require 'a2b_logging'

require 'pry'

def dummy_a2b_configs
  logger = ActiveSupport::Logger.new( File.join("requests.test.log") )
  log_stash_formatter = A2bLogging::Formatters::LogStashFormatter.new
  logger.formatter = log_stash_formatter

  ActiveSupport::OrderedOptions.new.tap do |a2b_config|
    a2b_config.unsubscribe_rails_defaults = true
    a2b_config.instrumentations = [ 
      { name: 'process_action.action_controller',
        block: lambda do |event|
          data = DataBuilders::RequestsData.build(event)
          logger.info(data)
        end,
        logger: logger
      }
    ]
  end
end

def default_patterns
  ActiveSupport::LogSubscriber.log_subscribers.map(&:patterns).flatten
end

def default_patterns_listeners
  default_patterns.map do |p|
    ActiveSupport::Notifications.notifier.listeners_for(p)
  end.flatten
end

def mock_application_with(configs)
  double(config: double(a2b_logging: configs))
end