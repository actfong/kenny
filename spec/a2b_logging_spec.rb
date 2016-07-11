require "spec_helper"

describe A2bLogging do

  let(:application_with_a2b){double(config: app_config_with_a2b)}
  let(:app_config_with_a2b) do
    double(a2b_logging: dummy_a2b_configs)
  end

  let(:application_without_a2b){double(config: app_config_without_a2b)}  
  let(:app_config_without_a2b) do
    double(a2b_logging: {})
  end

  describe ".attach_to_instrumentations" do

    context "config[:instrumentations] have been set with :name, :block and :logger " do
      before do
        A2bLogging.application = application_with_a2b
      end

      it "adds an LogSubscriber" do
        expect{ subject.attach_to_instrumentations }.to change{
          ActiveSupport::LogSubscriber.log_subscribers.count
        }.by 1        
      end

      it "the added LogSubscriber is inherited from A2bLogging::LogSubscriber" do
        log_subscribers_before = ActiveSupport::LogSubscriber.log_subscribers.clone
        subject.attach_to_instrumentations
        log_subscribers_after = ActiveSupport::LogSubscriber.log_subscribers.clone

        added_log_subscriber = (log_subscribers_after - log_subscribers_before).first

        expect(
          added_log_subscriber.class.superclass
        ).to eq A2bLogging::LogSubscriber
      end

      it "the added LogSubscriber listens to the specified instrumentation" do
        log_subscribers_before = ActiveSupport::LogSubscriber.log_subscribers.clone
        subject.attach_to_instrumentations
        log_subscribers_after = ActiveSupport::LogSubscriber.log_subscribers.clone

        added_log_subscriber = (log_subscribers_after - log_subscribers_before).first

        instrumentation = A2bLogging.application.config.a2b_logging[:instrumentations].first[:name]        
        listener = ActiveSupport::Notifications.notifier.listeners_for(instrumentation)[-1]

        expect(added_log_subscriber).to eq listener.instance_variable_get(:@delegate)
      end

      it "any instance of the added LogSubscriber class will return the same instance of the specified logger" do
        log_subscribers_before = ActiveSupport::LogSubscriber.log_subscribers.clone
        subject.attach_to_instrumentations
        log_subscribers_after = ActiveSupport::LogSubscriber.log_subscribers.clone

        added_log_subscriber = (log_subscribers_after - log_subscribers_before).first

        expect(added_log_subscriber.logger.object_id).to eq added_log_subscriber.class.new.logger.object_id
      end
    end

    context "logger hasn't been defined" do
      before do
        cloned_configs = dummy_a2b_configs.clone
        cloned_configs[:instrumentations].first.delete(:logger)
        app = mock_application_with(cloned_configs)
        A2bLogging.application = app        
      end

      it "won't assign a logger" do
        log_subscribers_before = ActiveSupport::LogSubscriber.log_subscribers.clone
        subject.attach_to_instrumentations
        log_subscribers_after = ActiveSupport::LogSubscriber.log_subscribers.clone
        added_log_subscriber = (log_subscribers_after - log_subscribers_before).first

        expect(added_log_subscriber.logger).to be_nil
      end
    end

    context "config[:instrumentations] not set" do
      before do
        A2bLogging.application = application_without_a2b
      end

      it "won't add extra LogSubscribers" do  
        expect{ 
          subject.attach_to_instrumentations
        }.not_to change{
          ActiveSupport::LogSubscriber.log_subscribers
        }
      end
    end
  end

  describe ".unsubscribe_from_rails_defaults" do
    context "config[:unsubscribe_rails_defaults] is truthy" do
      before do
        A2bLogging.application = application_with_a2b
      end

      it "delegates to A2bLogging::Unsubscriber" do
        expect(A2bLogging::Unsubscriber).to receive(:unsubscribe_from_rails_defaults)
        subject.unsubscribe_from_rails_defaults
      end
    end

    context "config[:unsubscribe_rails_defaults] is not truthy" do
      before do
        A2bLogging.application = application_without_a2b
      end

      it "does not invoke A2bLogging::Unsubscriber.unsubscribe_from_rails_defaults" do
        expect(A2bLogging::Unsubscriber).not_to receive(:unsubscribe_from_rails_defaults)
        subject.unsubscribe_from_rails_defaults
      end      
    end
  end
end
