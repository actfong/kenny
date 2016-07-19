##

# Kenny module does three things:
# - Holds reference to the Rails application (set through Railtie)
# - Unsubscribe all Rails' LogSubscribers from the default instrumentation channels
# - Create LogSubscriber-classes which will be attached to the user-specified instrumentations
module Kenny
  def self.configs
    Struct.new(
      :unsubscribe_rails_defaults,
      :suppress_rack_logger,
      :instrumentations
    ).new
  end

  def self.application=(app)
    @application = app
  end

  def self.application
    @application
  end

  ##
  # Define LogSubscriber-classes and Attach to user-specified instrumentations
  # if the configurations have been set.
  def self.attach_to_instrumentations
    if @application.config.kenny[:instrumentations]
      @application.config.kenny[:instrumentations].each do |instr_config|
        define_log_subscriber_class(instr_config)
      end
    end
  end

  ##
  # Unsubscribe all Rails' default LogSubscribers from the default Rails instrumentations,
  # by delegating to Kenny::Unsubscriber.
  # See http://edgeguides.rubyonrails.org/active_support_instrumentation.html
  def self.unsubscribe_from_rails_defaults
    if @application.config.kenny[:unsubscribe_rails_defaults]
      Kenny::Unsubscriber.unsubscribe_from_rails_defaults
    end
  end

  ##
  # Suppress Rails::Rack::Logger's output like:
  #   Started GET "/my_path" for 10.0.2.2 at 2016-07-12 10:06:48 +0000
  def self.suppress_rack_logger
    if @application.config.kenny[:suppress_rack_logger]
      require 'kenny/rails_ext/rack/logger'
    end
  end

  ##
  # Create LogSubscriber-classes which will be attached to the user-specified instrumentations
  # These classes are anonymous, but inherit from Kenny::LogSubscriber to simplify testing
  #
  # Within these classes, methods (and potentially `def logger`) are defined based on the
  # instrumentations-configs provided by the user.
  def self.define_log_subscriber_class(instr_config)
    klass = Class.new(Kenny::LogSubscriber) do |k|
      define_method(instr_config[:name].split('.')[0], instr_config[:block])

      if instr_config[:logger]
        # Following assignment needed as we don't want to have
        # the lambda being re-evaluated and possibly return
        # a new logger instance everytime the .logger method is invoked.
        defined_logger = instr_config[:logger]
        define_method(:logger, lambda { defined_logger })
      end
    end
    klass.attach_to instr_config[:name].split('.')[1].to_sym
  end
  private_class_method :define_log_subscriber_class
end

require 'kenny/railtie'

require 'kenny/formatters/log_stash_formatter'
require 'kenny/unsubscriber'
require 'kenny/log_subscriber'
