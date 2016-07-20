require 'logger'
require 'logstash-event'
require 'active_support'

module Kenny
  module Formatters
    # Formats messages as LogStash::Event
    class LogStashFormatter < ::Logger::Formatter
      include ActiveSupport::TaggedLogging::Formatter

      def call(severity, time, progname, msg)
        msg = { 'message' => msg.is_a?(String) ? msg : msg.inspect } unless msg.is_a?(Hash)

        msg['severity'] = severity if severity
        msg['progname'] = progname if progname

        tags = current_tags

        if tags.any?
          msg['type'] ||= tags.first
          msg['tags'] = tags
        end

        event = LogStash::Event.new(msg)

        "%s\n" % event.to_json
      end
    end
  end
end
