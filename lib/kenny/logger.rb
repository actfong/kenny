module Kenny
  ##
  # Basically does exactly the same as an ActiveSupport::Logger
  # The only difference is that it comes with a Kenny::Formatters::LogStashFormatter by default
  class Logger < ActiveSupport::Logger
    def initialize(filename)
      super(filename)
      @formatter = Kenny::Formatters::LogStashFormatter.new
    end
  end
end
