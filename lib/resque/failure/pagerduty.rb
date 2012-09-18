module Resque
  module Failure
    # A Resque failure backend that handles exceptions by triggering
    # incidents in the Pagerduty API
    class Pagerduty < Base
      class << self
        # The subdomain for the Pagerduty endpoint url
        attr_accessor :subdomain

        # The default GUID of the Pagerduty "Generic API" service to be notified.
        # This is the "service key" listed on a Generic API's service detail page
        # in the Pagerduty app.
        attr_accessor :service_key

        # The user for authenticating to Pagerduty
        attr_accessor :username

        # The password for authenticating to Pagerduty
        attr_accessor :password
      end

      # The GUID of the Pagerduty "Generic API" service to be notified.
      # If a pagerduty_service_key is provided on the payload class, then the
      # payload service_key will be used; otherwise, the default service_key
      # can be configured on the failure backend class.
      #
      # @see .configure
      # @see .service_key
      def service_key
        if payload['class'].respond_to?(:pagerduty_service_key)
          payload['class'].pagerduty_service_key
        else
          self.class.service_key
        end
      end

      # Configures the failure backend. Minimally, you will need
      # to set a Pagerduty subdomain and service_key.
      #
      # @example Minimal configuration
      #   Resque::Failure::Pagerduty.configure do |config|
      #     config.subdomain = 'my_subdomain'
      #     config.service_key = '123abc456def'
      #   end
      #
      # @example Full configuration
      #   Resque::Failure::Pagerduty.configure do |config|
      #     config.subdomain = 'my_subdomain'
      #     config.service_key = '123abc456def'
      #     config.username = 'my_user'
      #     config.password = 'my_pass'
      #   end
      def self.configure
        yield self
        self
      end

      # Resets configured values.
      # @see .configure
      def self.reset
        self.subdomain = nil
        self.service_key = nil
        self.username = nil
        self.password = nil
      end
    end
  end
end
