require 'logger'
require 'logstash-event'

module A2bLogging
  class Formatter < ::Logger::Formatter

    def tagged(*tags)
      new_tags = push_tags(*tags)
      yield self
    ensure
      pop_tags(new_tags.size)
    end

    def push_tags(*tags)
      tags.flatten.reject(&:blank?).tap do |new_tags|
        current_tags.concat new_tags
      end
    end

    def pop_tags(size = 1)
      current_tags.pop size
    end

    def clear_tags!
      current_tags.clear
    end

    def current_tags
      Thread.current[:activesupport_tagged_logging_tags] ||= []
    end

    def call(severity, time, progname, msg)

      if not msg.is_a?(Hash)
        msg = { 'message' => String === msg ? msg : msg.inspect }
      end

      msg['severity'] = severity if severity
      msg['progname'] = progname if progname

      tags = current_tags

      if tags.any?
        if not msg['type']
          msg['type'] = tags.at(0)
        end
        msg['tags'] = tags
      end

      event = LogStash::Event.new(msg)

      "%s\n" % event.to_json
    end
  end
end
