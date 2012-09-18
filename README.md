# Resque Pagerduty #

A [Resque][resque] failure backend for triggering incidents in [Pagerduty][pagerduty].

## Documentation ##

**TODO**

## Installation ##

**TODO**

## Examples ##

### Pagerduty Configuration ###

Minimally, you'll need to configure the failure backend with enough information to trigger an incident in the [Pagerduty Integration API][pd-integration-api]:

    Resque::Pagerduty::Failure.configure do |config|
      config.subdomain = 'my_domain'
      config.service_key = 'abc123def456'
    end

The above configuration will the backend to trigger incidents at pagerduty service identified by the service key GUID (it must be set up as a "Generic API" service inside pagerduty) at the https://my_domain.pagerduty.com endpoint.

You may want to have different jobs trigger incidents in different services. The failure backend will automatically look for a class method named `pagerduty_service_key` on the resque payload class, and will preferentially use that value. Otherwise, it will default to using the service_key configured on the backend itself. For example:

    class MyJob
      @queue = :my_queue

      def self.pagerduty_service_key
        'my_custom_service_key'
      end

      def self.perform(my_arg)
        # Some code that could throw an exception goes here
      end
    end

If the `MyJob.perform` method throws an exception during processing, the failure backend would use the `MyJob.pagerduty_service_key` instead of the `Resque::Pagerduty::Failure.service_key` to trigger the incident.

 [resque]: https://github.com/defunkt/resque
 [pagerduty]: http://pagerduty.com
 [pd-integration-api]: http://developer.pagerduty.com/documentation/integration/events
