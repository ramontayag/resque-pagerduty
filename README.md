# resque-pagerduty #

A [Resque][resque] failure backend for triggering incidents in [Pagerduty][pagerduty].

## Documentation ##

Complete documentation for this gem is on [rubydoc.info][rubydoc].

More general information about resque failure backends is on the
[official resque wiki][resque-failure].

## Installation ##

To install from [rubygems][rubygems]:

    $ gem install resque-pagerduty

To use with bundler without adding explicit require statements to your code,
add the following to your Gemfile:

    gem 'resque-pagerduty', :require => 'resque_pagerduty'

## Examples ##

### Pagerduty Configuration ###

You'll need to configure the failure backend with enough information to
trigger an incident in the [Pagerduty Integration API][pd-integration-api]:

    Resque::Failure::Pagerduty.configure do |config|
      config.service_key = 'my_pagerduty_service_key'
    end

The above configuration will cause the backend to handle all exceptions by triggering
incidents at the Pagerduty service identified by the service key GUID (it must be set
up as a "Generic API" service within Pagerduty).

However, you may want to have different jobs trigger incidents in different Pagerduty
services. When handling an exception, the failure backend will automatically look for
a class method named `pagerduty_service_key` on the resque payload class, and will
preferentially use that callback. If this callback does not exist on the job class,
it will default to using the `service_key` configured on the backend itself. For example:

    class MyJob
      @queue = :my_queue

      def self.pagerduty_service_key
        'my_custom_service_key'
      end

      def self.perform(my_arg)
        # Some code that could raise an exception goes here
      end
    end

If the `MyJob.perform` method raises an exception during processing, the failure
backend would use the `MyJob.pagerduty_service_key` instead of the
`Resque::Failure::Pagerduty.service_key` to trigger the incident.

### Single Resque Failure Backend ###

Using only the Pagerduty failure backend:

    require 'resque/failure/pagerduty'

    Resque::Failure::Pagerduty.configure do |config|
      config.service_key = 'my_pagerduty_service_key'
    end

    Resque::Failure.backend = Resque::Failure::Pagerduty

### Multiple Resque Failure Backends ###

Using both the Redis and Pagerduty failure backends:

    require 'resque/failure/pagerduty'
    require 'resque/failure/redis'
    require 'resque/failure/multiple'

    Resque::Failure::Pagerduty.configure do |config|
      config.service_key = 'my_pagerduty_service_key'
    end

    Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Pagerduty]
    Resque::Failure.backend = Resque::Failure::Multiple

 [resque-failure]: https://github.com/defunkt/resque/wiki/Failure-Backends
 [rubydoc]: http://rubydoc.info/gems/resque-pagerduty/frames
 [rubygems]: http://rubygems.org/gems/resque-pagerduty
 [resque]: https://github.com/defunkt/resque
 [pagerduty]: http://pagerduty.com
 [pd-integration-api]: http://developer.pagerduty.com/documentation/integration/events
