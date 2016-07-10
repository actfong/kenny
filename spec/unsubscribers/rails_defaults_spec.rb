require "spec_helper"

describe A2bLogging::Unsubscribers::RailsDefaults do
  let(:default_patterns){
    ActiveSupport::LogSubscriber.log_subscribers.map(&:patterns).flatten
  }

  let(:default_patterns_listeners) do
    lambda do
      default_patterns.map do |p|
        ActiveSupport::Notifications.notifier.listeners_for(p)
      end.flatten
    end
  end

  let(:application){double(config: app_config)}

  let(:app_config) do
    double(a2b_logging: dummy_a2b_configs)
  end

  before do
    A2bLogging.application = application
  end

  describe ".unsubscribe_all" do
    context "No custom LogSubscribers attached" do
      it 'removes listeners_for default_patterns' do
        before_count = default_patterns_listeners.call.count
        A2bLogging::Unsubscribers::RailsDefaults.unsubscribe_all
        after_count = default_patterns_listeners.call.count

        expect(before_count).not_to eq after_count
        expect(after_count).to eq 0
      end
    end

    context "Custom A2bLogging LogSubscribers attached" do

      it "keeps only the Custom LosSubscriber as listener" do
        before_count = default_patterns_listeners.call.count

        A2bLogging.attach_to_instrumentation
        A2bLogging::Unsubscribers::RailsDefaults.unsubscribe_all

        after_count = default_patterns_listeners.call.count

        expect(before_count).not_to eq after_count
        expect(after_count).to eq 2 

        ["process_action.action_controller", "logger.action_controller"].each do |instr|
          expect(
            default_patterns_listeners.call.map{ |sub| sub.instance_variable_get "@pattern" } 
          ).to include instr
        end
      end
    end

  end
end
