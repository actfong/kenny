require 'a2b_logging'

require 'pry'

def dummy_a2b_configs
  ActiveSupport::OrderedOptions.new.tap do |a2b_config|
    a2b_config.unsubscribe_rails_defaults = true,
    a2b_config.instrumentations = [ 
      { name: 'process_action.action_controller',
        block: lambda do |event|
          data = DataBuilders::RequestsData.build(event)
          logger.info(data)
        end,
        logger: lambda do 
          logger = ActiveSupport::Logger.new( File.join( Rails.root, "log", "requests.test.log"))
          logger.formatter = A2bLogging::Formatters::A2b_Formatter.new
          logger
        end
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
