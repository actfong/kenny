require 'spec_helper'

describe Kenny::Unsubscriber do
  let(:application_with_kenny) { double(config: app_config_with_kenny) }
  let(:app_config_with_kenny) do
    double(kenny: dummy_kenny_configs)
  end

  describe '.unsubscribe_from_rails_defaults' do
    before do
      Kenny.application = application_with_kenny
    end

    it 'removes listeners_for default_patterns' do
      expect do
        Kenny::Unsubscriber.unsubscribe_from_rails_defaults
      end.to change{
        default_patterns_listeners.count
      }

      log_subscribers = default_patterns_listeners.map { |listener| listener.instance_variable_get(:@delegate) }

      log_subscribers.each do |ls|
        expect(ls.class).not_to be_in Kenny::Unsubscriber::DEFAULT_RAILS_LOG_SUBSCRIBER_CLASSES
      end
    end

    it 'leaves the Kenny:Unsubscriber attached' do
      Kenny.attach_to_instrumentations
      Kenny::Unsubscriber.unsubscribe_from_rails_defaults

      log_subscribers = default_patterns_listeners.map { |listener| listener.instance_variable_get(:@delegate) }

      log_subscribers.each do |ls|
        expect(ls.class.superclass).to be Kenny::LogSubscriber
      end
    end
  end
end
