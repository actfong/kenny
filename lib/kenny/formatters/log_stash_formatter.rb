require 'logger'
require 'logstash-event'
require 'active_support'

module Kenny
  module Formatters
    ##
    # Formats messages as LogStash::Event
    # the 'type' field can be used for ElasticSearch
    # The 'type' could be set through the Logger's progname,
    # which takes the highest precedence.
    # If logger.progname.nil?, it will take the 'type' within the hash.
    # If the 'type' within the Hash is also nil,
    # then you can set the type through FileBeat's config
    class LogStashFormatter < ::Logger::Formatter
      def call(severity, time, progname, msg)
        msg = { 'message' => msg.is_a?(String) ? msg : msg.inspect } unless msg.is_a?(Hash)
        msg['severity'] = severity if severity
        msg['type'] = progname if progname

        event = LogStash::Event.new(msg)

        "%s\n" % clean_json!(event.to_json)
      end

      private

      def clean_json!(json_string)
        json_string.gsub(/\\u([0-9a-z]{4})/) { [$1.to_i(16)].pack('U') }
      end
    end
  end
end
