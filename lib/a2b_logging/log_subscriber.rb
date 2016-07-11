## 
# This class is meant to be inherited by anonymous classes, 
# created through A2bLogging.define_log_subscriber_class.
#
# By inserting this class into the inheritance tree, 
# we can verify in test-environment whether the LogSubscribers 
# we created are indeed attached to the instrumentations we specified.
module A2bLogging
  class LogSubscriber < ActiveSupport::LogSubscriber
  end
end
