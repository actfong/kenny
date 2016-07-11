require "spec_helper"

describe A2bLogging::Unsubscriber do

  let(:application_with_a2b){double(config: app_config_with_a2b)}
  let(:app_config_with_a2b) do
    double(a2b_logging: dummy_a2b_configs)
  end

  describe ".unsubscribe_from_rails_defaults" do

    before do
      A2bLogging.application = application_with_a2b
    end

    it 'removes listeners_for default_patterns' do
      expect{ 
        A2bLogging::Unsubscriber.unsubscribe_from_rails_defaults
      }.to change{ 
        default_patterns_listeners.count
      }

      log_subscribers = default_patterns_listeners.map{ |listener| listener.instance_variable_get(:@delegate) }

      log_subscribers.each do |ls|
        expect(ls.class).not_to be_in A2bLogging::Unsubscriber::DEFAULT_RAILS_LOG_SUBSCRIBER_CLASSES
      end        
    end

    it "leaves the A2bLogging:Unsubscriber attached" do
      A2bLogging.attach_to_instrumentations
      A2bLogging::Unsubscriber.unsubscribe_from_rails_defaults

      log_subscribers = default_patterns_listeners.map{ |listener| listener.instance_variable_get(:@delegate) }

      log_subscribers.each do |ls|
        expect(ls.class.superclass).to be A2bLogging::LogSubscriber
      end
    end

  end
end
