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
      if app.config.a2b_logging[:instrumentations]
        app.config.a2b_logging[:instrumentations].each do |instr_config|
          define_log_subscriber_class(instr_config)
        end
      end
    end

    config.after_initialize do |app|
      # Unsubscribe all default Rails LogSubscribers 
      if app.config.a2b_logging[:unsubscribe_rails_defaults]
        A2bLogging::Unsubscribers::RailsDefaults.unsubscribe_all
      end
    end

    def define_log_subscriber_class(instr_config)
      klass = Class.new(ActiveSupport::LogSubscriber) do
        define_method( instr_config[:name].split(".")[0], instr_config[:block] )

        if instr_config[:logger]
          define_method(:logger, instr_config[:logger] )
        else
          define_method(:logger, lambda{Rails.logger})
        end

      end
      klass.attach_to instr_config[:name].split(".")[1].to_sym
    end

  end
end
