require 'resque'
require 'redphone/pagerduty'
require 'resque/failure/generates_pagerduty_desc'

module Resque
  module Failure
    # A Resque failure backend that handles exceptions by triggering
    # incidents in the Pagerduty API
    class Pagerduty < Base
      class << self
        # The default GUID of the Pagerduty "Generic API" service to be notified.
        # This is the "service key" listed on a Generic API's service detail page
        # in the Pagerduty app.
        attr_accessor :service_key
      end

      # The GUID of the Pagerduty "Generic API" service to be notified.
      # If a `pagerduty_service_key` callback is implemented on the payload
      # class, then that will be used. Otherwise, the default
      # {Resque::Failure::Pagerduty.service_key} will be used.
      #
      # @see .configure
      def service_key
        payload_class = Module.const_get(payload['class'])
        if (payload_class.respond_to?(:pagerduty_service_key) &&
            !payload_class.pagerduty_service_key.nil?)
          payload_class.pagerduty_service_key
        else
          self.class.service_key
        end
      end

      # Configure the failure backend for the Pagerduty API.
      #
      # @example Minimal configuration
      #   Resque::Failure::Pagerduty.configure do |config|
      #     config.service_key = '123abc456def'
      #   end
      #
      # @see .service_key
      def self.configure
        yield self
        self
      end

      # Reset configured values.
      # @see .configure
      def self.reset
        self.service_key = nil
      end

      # Trigger an incident in Pagerduty when a job fails.
      def save
        if service_key
          pagerduty_client.trigger_incident(
            :description => description,
            :details => {:queue => queue,
                         :worker => worker.to_s,
                         :payload => payload,
                         :exception => {:class => exception.class.name,
                                        :message => exception.message,
                                        :backtrace => exception.backtrace}}
          )
        end
      end

      private

      def description
        @description ||= GeneratesPagerdutyDesc.execute(exception, payload)
      end

      def pagerduty_client
        Redphone::Pagerduty.new(
          :service_key => service_key,
          :subdomain => '',
          :user => '',
          :password => ''
        )
      end
    end
  end
end
