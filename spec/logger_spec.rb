require 'spec_helper'

RSpec.describe Kenny::Logger do
  subject(:logger) { Kenny::Logger.new('kenny.test.log') }

  describe 'default formatter' do
    specify { expect(subject.formatter).to be_an_instance_of Kenny::Formatters::LogStashFormatter }
  end
end
