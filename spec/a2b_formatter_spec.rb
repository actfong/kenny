require 'spec_helper'
require 'active_support'

RSpec.describe A2bLogging::Formatter, "A2BFormatter" do
  describe "the json output" do
    subject { JSON.parse(strio.string) }

    let(:strio) { StringIO.new }
    let(:logger) { ActiveSupport::Logger.new(strio) }
    let(:tagged_logger) { ActiveSupport::TaggedLogging.new(logger) }

    context "when not using tags" do
      before do
        tagged_logger.formatter = A2bLogging::Formatter.new
        tagged_logger.info log_input
      end

      context "and logging a string" do
        let(:log_input) { "hello world" }

        it "uses the string as message" do
          expect(subject['message']).to eq "hello world"
        end

        it "has a correct timestamp" do
          expect(Time.parse(subject['@timestamp'])).to be_within(2).of Time.now
        end
      end

      context "and logging an object" do
        let(:log_input) { { type: "foo", test: 123 } }

        it "contains the data in the correct field" do
          expect(subject['test']).to eq 123
        end

        it "has a correct timestamp" do
          expect(Time.parse(subject['@timestamp'])).to be_within(2).of Time.now
        end

        it "has a field type containing the type" do
          expect(subject['type']).to eq "foo"
        end
      end
    end

    context "when using tags" do
      before do
        tagged_logger.formatter = A2bLogging::Formatter.new
        tagged_logger.tagged("test_type") do
          tagged_logger.tagged("test_tag") do
            tagged_logger.info "foobar"
          end
        end
      end

      it "uses the string as message" do
        expect(subject['message']).to eq "foobar"
      end

      it "has a correct timestamp" do
        expect(Time.parse(subject['@timestamp'])).to be_within(2).of Time.now
      end

      it "has the correct type" do
        expect(subject['type']).to eq "test_type"
      end

      it "has the correct tags" do
        expect(subject['tags']).to eq ["test_type","test_tag"]
      end
    end
  end
end
