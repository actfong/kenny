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
        msg['rails_env'] = Rails.env.to_sym

        event = LogStash::Event.new(msg)

        "%s\n" % event.to_json
      end
    end
  end
end
