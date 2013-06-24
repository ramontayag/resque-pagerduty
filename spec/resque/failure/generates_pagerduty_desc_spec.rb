require 'spec_helper'

describe Resque::Failure::GeneratesPagerdutyDesc do
  describe '.execute' do
    let(:payload) { {'class' => 'PayloadClass'} }

    context 'the complete description is 118 characters or more' do
      let(:exception) { ArgumentError.new('very long message'*8) }

      it 'should return a truncated description ending with an ellipsis' do
        message = described_class.execute(exception, payload)
        expect(message).to include('ArgumentError in PayloadClass: very long message')
        expect(message).to match(/\.{3}$/)
        expect(message.length).to eq(120)
      end
    end

    context 'the complete description is less than 118 characters' do
      let(:exception) { ArgumentError.new('My message') }

      it 'should return the complete description' do
        expect(described_class.execute(exception, payload)).
          to eq('ArgumentError in PayloadClass: My message')
      end
    end
  end
end
