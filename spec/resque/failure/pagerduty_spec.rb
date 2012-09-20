require 'spec_helper'

describe Resque::Failure::Pagerduty do
  after { Resque::Failure::Pagerduty.reset }

  describe 'instance methods' do
    subject { backend }
    let(:backend) { Resque::Failure::Pagerduty.new(exception, worker, queue, payload) }

    let(:exception) do
      error = StandardError.new('This is a test exception message')
      error.set_backtrace(['dummy_file.rb:23','dummy_file.rb:42'])
      error
    end

    let(:worker) { mock(:worker, :log => nil) }
    let(:queue) { 'my_queue' }

    let(:payload) do
      {'class' => payload_class.name,
       'arguments' => payload_args}
    end
    let(:payload_class) { Class.new }
    before { stub_const('TestPayloadClass', payload_class) }

    let(:payload_args) { [] }

    describe '#initialize' do
      its(:exception) { should == exception }
      its(:worker) { should == worker }
      its(:queue) { should == queue }
      its(:payload) { should == payload }
    end

    describe '#service_key' do
      subject { backend.service_key }

      context 'when the backend class has a service_key' do
        before { Resque::Failure::Pagerduty.service_key = default_service_key }
        let(:default_service_key) { 'class123abc456def' }

        context 'when the payload class has a pagerduty_service_key' do
          before { payload_class.stub(:pagerduty_service_key => payload_service_key) }
          let(:payload_service_key) { 'payloadfed654cba321' }

          it { should == payload_service_key }
        end

        context 'when the payload class does not respond to service_key' do
          it { should == default_service_key }
        end

        context 'when the payload class has a nil service_key' do
          before { payload_class.stub(:pagerduty_service_key => nil) }

          it { should == default_service_key }
        end
      end

      context 'when the backend class has no service_key' do
        context 'when the payload class has a service_key' do
          before { payload_class.stub(:pagerduty_service_key => payload_service_key) }
          let(:payload_service_key) { 'payloadfed654cba321' }

          it { should == payload_service_key }
        end

        context 'when the payload class does not respond to service_key' do
          it { should be_nil }
        end

        context 'when the payload class has a nil service_key' do
          before { payload_class.stub(:pagerduty_service_key => nil) }

          it { should be_nil }
        end
      end
    end

    describe '#save' do
      subject(:save) { backend.save }

      before do
        stub_request(:any, /.*\.pagerduty\.com.*/).to_return(
          :status => 200,
          :headers => {'Content-Type' => 'application/json'},
          :body => {'status' => 'success',
                    'message' => 'Event processed',
                    'incident_key' => '112358abcdef'}.to_json
        )
      end

      context 'when there is a service key' do
        before { Resque::Failure::Pagerduty.service_key = service_key }
        let(:service_key) { 'my_key' }

        it 'should send a post request to the pagerduty api' do
          save
          a_request(:post, /.*\.pagerduty\.com/).should have_been_made
        end

        it 'should call the pagerduty api with the correct endpoint' do
          save
          a_request(:any, 'https://events.pagerduty.com/generic/2010-04-15/create_event.json').should have_been_made
        end

        it 'should call the pagerduty api with the correct service key' do
          save
          a_request(:any, /.*\.pagerduty\.com/).with(:body => /"service_key":"#{service_key}"/).should have_been_made
        end

        it 'should call the pagerduty api with the correct event_type' do
          save
          a_request(:any, /.*\.pagerduty\.com/).with(:body => /"event_type":"trigger"/).should have_been_made
        end

        it 'should call the pagerduty api with the correct description' do
          save
          a_request(:any, /.*\.pagerduty\.com/).with(:body => /"description":"Job raised an error: #{exception.to_s}"/).should have_been_made
        end

        it 'should call the pagerduty api with the correct class in the details' do
          save
          a_request(:any, /.*\.pagerduty\.com/).with(:body => /"details":\{.*"class":"#{payload_class.to_s}".*\}/).should have_been_made
        end

        it 'should call the pagerduty api with the correct args in the details' do
          save
          a_request(:any, /.*\.pagerduty\.com/).with(:body => /"details":\{.*"args":\[\].*\}/).should have_been_made
        end

        it 'should call the pagerduty api with the correct queue in the details' do
          save
          a_request(:any, /.*\.pagerduty\.com/).with(:body => /"details":\{.*"queue":"#{queue}".*\}/).should have_been_made
        end

        it 'should call the pagerduty api with the correct exception in the details' do
          save
          a_request(:any, /.*.pagerduty.com/).with(:body => /"details":\{.*"exception":"#{exception.inspect}".*\}/).should have_been_made
        end

        it 'should call the pagerduty api with the correct backtrace in the details' do
          save
          a_request(:any, /.*.pagerduty.com/).with(:body => /"details":\{.*"backtrace":"dummy_file.rb:23\\ndummy_file.rb:42".*\}/).should have_been_made
        end
      end

      context 'when there is no service key' do
        it 'should not attempt to trigger an incident in pagerduty' do
          save
          a_request(:any, /.*.pagerduty.com/).should_not have_been_made
        end
      end
    end

    it { should respond_to(:log) }
  end

  describe 'class methods' do
    subject { Resque::Failure::Pagerduty }

    describe '.configure' do
      subject(:configure) do
        Resque::Failure::Pagerduty.configure do |config|
          config.service_key = service_key
        end
      end

      let(:service_key) { 'my_key' }

      it 'should change the service key on the backend class' do
        expect { configure }.to change { Resque::Failure::Pagerduty.service_key }.to(service_key)
      end
    end

    describe '.reset' do
      subject(:reset) { Resque::Failure::Pagerduty.reset }

      before do
        Resque::Failure::Pagerduty.configure do |config|
          config.service_key = 'foo'
        end
      end

      it 'should change the service key on the backend class' do
        expect { reset }.to change { Resque::Failure::Pagerduty.service_key }.to(nil)
      end
    end

    it { should respond_to(:count) }
    it { should respond_to(:all) }
    it { should respond_to(:url) }
    it { should respond_to(:clear) }
    it { should respond_to(:requeue) }
    it { should respond_to(:remove) }
  end
end
