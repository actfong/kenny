require_relative "./a2b_logging/railtie"
require_relative "../rails_ext/rack/logger"

require_relative "./a2b_logging/formatters/log_stash_formatter"
require_relative "./a2b_logging/unsubscriber"
require_relative "./a2b_logging/log_subscriber"

module A2bLogging

  def self.application=(app)
    @@application = app
  end

  def self.application
    @@application
  end

  def self.attach_to_instrumentations
    if @@application.config.a2b_logging[:instrumentations]
      @@application.config.a2b_logging[:instrumentations].each do |instr_config|
        define_log_subscriber_class(instr_config)
      end
    end  
  end

  def self.unsubscribe_from_rails_defaults
    if @@application.config.a2b_logging[:unsubscribe_rails_defaults]
      A2bLogging::Unsubscriber.unsubscribe_all
    end
  end

  def self.define_log_subscriber_class(instr_config)
    klass = Class.new(A2bLogging::LogSubscriber) do
      define_method( instr_config[:name].split(".")[0], instr_config[:block] )

      if instr_config[:logger]
        define_method(:logger, instr_config[:logger] )
      else
        define_method(:logger, lambda{Rails.logger})
      end

    end
    klass.attach_to instr_config[:name].split(".")[1].to_sym
  end
  private_class_method :define_log_subscriber_class

end
