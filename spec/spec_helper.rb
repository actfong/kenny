require 'kenny'
require 'pry'

def dummy_kenny_configs
  request_logger = ActiveSupport::Logger.new(File.join('requests.test.log'))
  log_stash_formatter = Kenny::Formatters::LogStashFormatter.new
  request_logger.formatter = log_stash_formatter

  Kenny.configs.tap do |conf|
    conf.instrumentations = [
      {
        name: 'process_action.action_controller',
        block: lambda do |event|
          Date.parse '2016-01-01'
          logger.info(event.inspect)
        end,
        logger: request_logger
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
  double(config: double(kenny: configs))
end

def kenny_log_subscribers_for(event_name)
  listeners = listeners_for(event_name)
  delegates = listeners.map do |listener|
    listener.instance_variable_get :@delegate
  end
  delegates.select { |delegate| delegate.class.superclass == Kenny::LogSubscriber }
end

def listeners_for(event_name)
  ActiveSupport::Notifications.notifier.listeners_for(event_name)
end
