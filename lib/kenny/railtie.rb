require 'rails/railtie'
require 'action_view/log_subscriber'
require 'action_controller/log_subscriber'
require 'active_record/log_subscriber'
require 'action_mailer/log_subscriber'

module Kenny
  class Railtie < Rails::Railtie
    config.kenny = Kenny.configs

    config.after_initialize do |app|
      Kenny.application = app

      # Define anonymous classes that inherit from ActiveSupport::LogSubscriber.
      # Within that anonymous class, define methods that
      # perform the user-defined actions when that instrumentation occurs.
      # If desired, user can define a specific logger for the specified instrumentation.
      Kenny.attach_to_instrumentations

      # Unsubscribe all default Rails LogSubscribers if demanded
      Kenny.unsubscribe_from_rails_defaults

      # Suppress Rails::Rack::Logger's output
      Kenny.suppress_rack_logger
    end
  end
end
