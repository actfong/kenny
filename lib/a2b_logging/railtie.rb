require 'rails/railtie'
require 'action_view/log_subscriber'
require 'action_controller/log_subscriber'
require 'active_record/log_subscriber'
require 'action_mailer/log_subscriber'

module A2bLogging
  class Railtie < Rails::Railtie
    config.a2b_logging = ActiveSupport::OrderedOptions.new

    config.before_initialize do |app|
      # Define anonymous classes that inherit from ActiveSupport::LogSubscriber
      # Within that class, define methods that perform a user-define action when an instrumentation occurs
      # If desired, user can define a specific logger for the specified instrumentation
      A2bLogging.application = app
      A2bLogging.attach_to_instrumentations
    end

    config.after_initialize do |app|
      # Unsubscribe all default Rails LogSubscribers if demanded
      A2bLogging.unsubscribe_from_rails_defaults
    end
  end
end
