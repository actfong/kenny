require 'spec_helper'
require 'active_support'

RSpec.describe A2bLogging::Formatter, "A2BFormatter" do
  context "formatting a string" do
    strio = StringIO.new

    # match rails logger setup
    logger = ActiveSupport::Logger.new strio
    logger = ActiveSupport::TaggedLogging.new(logger)
    logger.formatter = A2bLogging::Formatter.new

    logger.info "hello world"
    json = JSON.parse(strio.string)

    it "uses the string as message" do
      expect(json['message']).to eq "hello world"
    end

    it "has a correct timestamp" do
      expect(Time.parse(json['@timestamp'])).to be_within(2).of Time.now
    end
  end

  context "formatting an object" do
    strio = StringIO.new

    # match rails logger setup
    logger = ActiveSupport::Logger.new strio
    logger = ActiveSupport::TaggedLogging.new(logger)
    logger.formatter = A2bLogging::Formatter.new

    logger.info( { "type" => "foo", "test" => 123 } )
    json = JSON.parse(strio.string)

    it "contains the data in the correct field" do
      expect(json['test']).to eq 123
    end

    it "has a correct timestamp" do
      expect(Time.parse(json['@timestamp'])).to be_within(2).of Time.now
    end

    it "has a field type containing the type" do
      expect(json['type']).to eq "foo"
    end
  end

  context "using tagged logging" do
    strio = StringIO.new

    # match rails logger setup
    logger = ActiveSupport::Logger.new strio
    logger = ActiveSupport::TaggedLogging.new(logger)
    logger.formatter = A2bLogging::Formatter.new

    logger.tagged("test_type") do
      logger.tagged("test_tag") do
        logger.info "foobar"
      end
    end

    json = JSON.parse(strio.string)

    it "uses the string as message" do
      expect(json['message']).to eq "foobar"
    end

    it "has a correct timestamp" do
      expect(Time.parse(json['@timestamp'])).to be_within(2).of Time.now
    end

    it "has the correct type" do
      expect(json['type']).to eq "test_type"
    end

    it "has the correct tags" do
      expect(json['tags']).to eq ["test_type","test_tag"]
    end

  end
end
