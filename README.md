# Resque Pagerduty #

A [Resque][resque] failure backend for triggering incidents in [Pagerduty][pagerduty].

## Documentation ##

**TODO**

## Installation ##

**TODO**

## Examples ##

### Pagerduty Configuration ###

You'll need to configure the failure backend with enough information to
trigger an incident in the [Pagerduty Integration API][pd-integration-api] or
query for incidents in the [Pagerduty REST API][pd-rest-api]:

    require 'resque_pagerduty'

    Resque::Failure::Pagerduty.configure do |config|
      config.subdomain = 'pagerduty_subdomain'
      config.username = 'my_pagerduty_user'
      config.password = 'my_pagerduty_password'
      config.service_key = 'my_pagerduty_service_key'
    end

The above configuration will the backend to trigger incidents at the Pagerduty
service identified by the service key GUID (it must be set up as a "Generic API"
service within Pagerduty).

The subdomain, username, and password should be the same for all of your resque jobs.
However, you may want to have different jobs trigger incidents in different Pagerduty
services. The failure backend will automatically look for a class method named
`pagerduty_service_key` on the resque payload class, and will preferentially
use that value. Otherwise, it will default to using the `service_key`
configured on the backend itself. For example:

    class MyJob
      @queue = :my_queue

      def self.pagerduty_service_key
        'my_custom_service_key'
      end

      def self.perform(my_arg)
        # Some code that could throw an exception goes here
      end
    end

If the `MyJob.perform` method throws an exception during processing, the failure
backend would use the `MyJob.pagerduty_service_key` instead of the
`Resque::Failure::Pagerduty.service_key` to trigger the incident.

### Single Resque Failure Backend ###

Using only the Pagerduty failure backend:

    require 'resque_pagerduty'

    Resque::Failure::Pagerduty.configure do |config|
      config.subdomain = 'pagerduty_subdomain'
      config.username = 'my_pagerduty_user'
      config.password = 'my_pagerduty_password'
      config.service_key = 'my_pagerduty_service_key'
    end

    Resque::Failure.backend = Resque::Failure::Pagerduty

### Multiple Resque Failure Backends ###

Using both the Redis and Pagerduty failure backends:

    require 'resque_pagerduty'
    require 'resque/failure/multiple'
    require 'resque/failure/redis'

    Resque::Failure::Pagerduty.configure do |config|
      config.subdomain = 'pagerduty_subdomain'
      config.username = 'my_pagerduty_user'
      config.password = 'my_pagerduty_password'
      config.service_key = 'my_pagerduty_service_key'
    end

    Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Pagerduty]
    Resque::Failure.backend = Resque::Failure::Multiple

 [resque]: https://github.com/defunkt/resque
 [pagerduty]: http://pagerduty.com
 [pd-integration-api]: http://developer.pagerduty.com/documentation/integration/events
 [pd-rest-api]: http://developer.pagerduty.com/documentation/rest
