require 'rails/railtie'
require 'action_view/log_subscriber'
require 'action_controller/log_subscriber'
require 'active_record/log_subscriber'
require 'action_mailer/log_subscriber'

module A2bLogging
  class Railtie < Rails::Railtie
    config.a2b_logging = ActiveSupport::OrderedOptions.new

    config.after_initialize do |app|
      A2bLogging.application = app

      # Define anonymous classes that inherit from ActiveSupport::LogSubscriber.
      # Within that anonymous class, define methods that 
      # perform the user-defined actions when that instrumentation occurs.
      # If desired, user can define a specific logger for the specified instrumentation.
      A2bLogging.attach_to_instrumentations

      # Unsubscribe all default Rails LogSubscribers if demanded
      A2bLogging.unsubscribe_from_rails_defaults
    end
  end
end
