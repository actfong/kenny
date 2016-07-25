require 'spec_helper'
require 'active_support'

RSpec.describe Kenny::Formatters::LogStashFormatter do
  describe 'the json output' do
    subject { JSON.parse(strio.string) }

    let(:strio) { StringIO.new }
    let(:logger) { ActiveSupport::Logger.new(strio) }

    context 'progname not set in logger' do
      before do
        logger.formatter = Kenny::Formatters::LogStashFormatter.new
        logger.info log_input
      end

      context 'and logging a string' do
        let(:log_input) { 'hello world' }

        it 'uses the string as message' do
          expect(subject['message']).to eq 'hello world'
        end

        it 'has a correct timestamp' do
          expect(Time.parse(subject['@timestamp'])).to be_within(2).of Time.now
        end

        it { expect(subject['type']).to be_nil }
      end

      context 'and logging an object' do
        context 'type set in hash' do
          let(:log_input) { { type: 'foo', test: 123 } }

          it 'contains the data in the correct field' do
            expect(subject['test']).to eq 123
          end

          it 'has a correct timestamp' do
            expect(Time.parse(subject['@timestamp'])).to be_within(2).of Time.now
          end

          it 'has a field type containing the type' do
            expect(subject['type']).to eq 'foo'
          end
        end

        context 'type NOT set in hash' do
          let(:log_input) { { test: 123 } }

          it { expect(subject['type']).to be_nil }
        end
      end
    end

    context 'progname has been set in logger' do
      before do
        logger.formatter = Kenny::Formatters::LogStashFormatter.new
        logger.progname = 'aspector'
        logger.info log_input
      end

      context 'logging a string' do
        let(:log_input) { 'hello world' }
        it 'uses the progname as type' do
          expect(subject['type']).to eq 'aspector'
        end
      end

      context 'logging a Hash without type in it' do
        let(:log_input) { { test: 123 } }
        it 'uses the logger.progname as type' do
          expect(subject['type']).to eq 'aspector'
        end
      end

      context 'logging a Hash with type in it' do
        let(:log_input) { { type: 'foo', test: 123 } }
        it 'gives progname precedence over type within the hash' do
          expect(subject['type']).to eq 'aspector'
        end
      end
    end

  end
end
