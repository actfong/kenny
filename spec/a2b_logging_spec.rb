require "spec_helper"

describe A2bLogging do

  let(:application){double(config: app_config)}

  let(:app_config) do
    double(a2b_logging: dummy_a2b_configs)
  end

  before do
    A2bLogging.application = application
  end  
  describe "attach_to_instrumentation" do
    it "expect an anoymous class < LogSubscriber to listen to event listed in config" do
      subject.attach_to_instrumentation
    end
  end

  describe ".unsubscribe_from_rails_defaults" do
    it "delegates to A2bLogging::Unsubscriber" do
      expect(A2bLogging::Unsubscriber).to receive(:unsubscribe_all)
      subject.unsubscribe_from_rails_defaults
    end
  end
end