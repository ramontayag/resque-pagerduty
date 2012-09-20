require 'resque'
require 'redphone/pagerduty'

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
      # If a pagerduty_service_key is provided on the payload class, then the
      # payload service_key will be used; otherwise, the default service_key
      # can be configured on the failure backend class.
      #
      # @see .configure
      # @see .service_key
      def service_key
        payload_class = Module.const_get(payload['class'])
        if (payload_class.respond_to?(:pagerduty_service_key) &&
            !payload_class.pagerduty_service_key.nil?)
          payload_class.pagerduty_service_key
        else
          self.class.service_key
        end
      end

      # Configures the failure backend for the Pagerduty API.
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

      # Resets configured values.
      # @see .configure
      def self.reset
        self.service_key = nil
      end

      # Trigger an incident in Pagerduty when a job fails.
      def save
        if service_key
          pagerduty_client.trigger_incident(
            :description => "Job raised an error: #{self.exception.to_s}",
            :details => {:queue => queue,
                         :class => payload['class'].to_s,
                         :args => payload['arguments'],
                         :exception => exception.inspect,
                         :backtrace => exception.backtrace.join("\n")}
          )
        end
      end

      private
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
