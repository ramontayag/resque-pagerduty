require 'spec_helper'

describe Resque::Failure::Pagerduty do
  describe 'instance methods' do
    subject do
      Resque::Failure::Pagerduty.new(exception, worker, queue, payload)
    end

    let(:exception) { mock(:exception) }
    let(:worker) { mock(:worker) }
    let(:queue) { mock(:queue) }
    let(:payload) { mock(:payload) }

    describe '#initialize' do
      its(:exception) { should == exception }
      its(:worker) { should == worker }
      its(:queue) { should == queue }
      its(:payload) { should == payload }
    end

    it { should respond_to(:save) }
    it { should respond_to(:log) }
  end

  describe 'class methods' do
    subject { Resque::Failure::Pagerduty }

    it { should respond_to(:count) }
    it { should respond_to(:all) }
    it { should respond_to(:url) }
    it { should respond_to(:clear) }
    it { should respond_to(:requeue) }
    it { should respond_to(:remove) }
  end
end
