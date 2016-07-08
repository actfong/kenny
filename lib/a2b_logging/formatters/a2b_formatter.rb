require 'logger'
require 'logstash-event'
require 'active_support'

module A2bLogging
  module Formatters
    class Formatter < ::Logger::Formatter

      include ActiveSupport::TaggedLogging::Formatter

      def call(severity, time, progname, msg)
        msg = { 'message' => msg.is_a?(String) ? msg : msg.inspect } unless msg.is_a?(Hash)

        msg['severity'] = severity if severity
        msg['progname'] = progname if progname

        tags = current_tags

        if tags.size > 0
          msg['type'] ||= tags.first
          msg['tags'] = tags
        end

        event = LogStash::Event.new(msg)

        "%s\n" % event.to_json
      end
    end
  end
end
