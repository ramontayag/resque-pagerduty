require 'spec_helper'

describe Resque::Failure::Pagerduty do
  after { Resque::Failure::Pagerduty.reset }

  describe 'instance methods' do
    subject { backend }
    let(:backend) { Resque::Failure::Pagerduty.new(exception, worker, queue, payload) }

    let(:exception) { mock(:exception) }
    let(:worker) { mock(:worker) }
    let(:queue) { mock(:queue) }

    let(:payload) do
      {'class' => payload_class,
       'arguments' => payload_args}
    end
    let(:payload_class) { mock(:payload_class) }
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
          before { payload_class.stub(:service_key => nil) }

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
          before { payload_class.stub(:service_key => nil) }

          it { should be_nil }
        end
      end
    end

    it { should respond_to(:save) }
    it { should respond_to(:log) }
  end

  describe 'class methods' do
    subject { Resque::Failure::Pagerduty }

    describe '.configure' do
      subject(:configure) do
        Resque::Failure::Pagerduty.configure do |config|
          config.subdomain = subdomain
          config.service_key = service_key
          config.username = username
          config.password = password
        end
      end

      let(:subdomain) { 'my_domain' }
      let(:service_key) { 'my_key' }
      let(:username) { 'my_user' }
      let(:password) { 'my_secret' }

      it 'should change the subdomain on the backend class' do
        expect { configure }.to change { Resque::Failure::Pagerduty.subdomain }.to(subdomain)
      end

      it 'should change the service key on the backend class' do
        expect { configure }.to change { Resque::Failure::Pagerduty.service_key }.to(service_key)
      end

      it 'should change the username on the backend class' do
        expect { configure }.to change { Resque::Failure::Pagerduty.username }.to(username)
      end

      it 'should change the password on the backend class' do
        expect { configure }.to change { Resque::Failure::Pagerduty.password }.to(password)
      end
    end

    describe '.reset' do
      subject(:reset) { Resque::Failure::Pagerduty.reset }

      before do
        Resque::Failure::Pagerduty.configure do |config|
          config.subdomain = 'foo'
          config.service_key = 'foo'
          config.username = 'foo'
          config.password = 'foo'
        end
      end

      it 'should change the subdomain on the backend class' do
        expect { reset }.to change { Resque::Failure::Pagerduty.subdomain }.to(nil)
      end

      it 'should change the service key on the backend class' do
        expect { reset }.to change { Resque::Failure::Pagerduty.service_key }.to(nil)
      end

      it 'should change the username on the backend class' do
        expect { reset }.to change { Resque::Failure::Pagerduty.username }.to(nil)
      end

      it 'should change the password on the backend class' do
        expect { reset }.to change { Resque::Failure::Pagerduty.password }.to(nil)
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
