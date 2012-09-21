# resque-pagerduty [![build status][build-img]][build-pg]

A Resque failure backend for triggering incidents in Pagerduty.

[build-img]: https://secure.travis-ci.org/maeve/resque-pagerduty.png
[build-pg]: http://travis-ci.org/#!/maeve/resque-pagerduty

## Dependencies ##

Depends on [Resque][resque] 1.7 or above.

Requires a subscription to [Pagerduty][pagerduty], with at least one Pagerduty
service configured with a service type of "Generic API".

[resque]: https://github.com/defunkt/resque
[pagerduty]: http://pagerduty.com

## Installation ##

To install from [Rubygems][rubygems]:

    $ gem install resque-pagerduty

To use with bundler without adding explicit require statements to your code,
add the following to your Gemfile:

    gem 'resque-pagerduty', :require => 'resque_pagerduty'

[rubygems]: http://rubygems.org/gems/resque-pagerduty

## Documentation ##

Complete documentation for this gem (including this README) is available on
[rubydoc.info][rubydoc].

General information about resque failure backends is available on the
[resque wiki][resque-failure].

The Pagerduty website provides more information about the
[Pagerduty Integration API][pd-integration-api].

[resque-failure]: https://github.com/defunkt/resque/wiki/Failure-Backends
[rubydoc]: http://rubydoc.info/gems/resque-pagerduty/frames
[pd-integration-api]: http://developer.pagerduty.com/documentation/integration/events

## Pagerduty Configuration ##

To trigger incidents in the same Pagerduty service across all jobs, configure
the failure backend with a Pagerduty service key:

    Resque::Failure::Pagerduty.configure do |config|
      config.service_key = 'my_pagerduty_service_key'
    end

This service must be set up as a "Generic API" service in Pagerduty. The
service key GUID can be found on the Pagerduty service details page.

You may want to have different jobs trigger incidents in different Pagerduty
services. When handling an exception, the failure backend will automatically
look for a class method named `pagerduty_service_key` on the resque payload
class, and will preferentially use that callback. If this callback does not
exist on the job class, it will default to using the `service_key` configured
on the backend itself. For example:

    class MyJob
      @queue = :my_queue

      def self.pagerduty_service_key
        'my_custom_service_key'
      end

      def self.perform(my_arg)
        # Some code that could raise an exception goes here
      end
    end

If the `MyJob.perform` method raises an exception during processing, the
failure backend would use the `MyJob.pagerduty_service_key` instead of the
`Resque::Failure::Pagerduty.service_key` to trigger the incident.

When there is no `Resque::Failure::Pagerduty.service_key` configured, and
there is no `pagerduty_service_key` callback defined on the job class, then the
failure backend will exit gracefully. This allows you to selectively enable
Pagerduty notifications for some jobs without enabling them for all jobs.

## Examples ##

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

## Contributing ##

1. [Fork the repository.][fork]
2. [Create a topic branch.][branch]
3. `bundle install`
4. `rake spec`
5. Implement your feature or bug fix, including [specs][rspec].
6. [Add, commit, and push][gitref] your changes to your fork.
7. [Submit a pull request.][pr]

[fork]: https://help.github.com/articles/fork-a-repo
[branch]: http://learn.github.com/p/branching.html
[rspec]: http://github.com/rspec/rspec
[gitref]: http://gitref.org/
[pr]: http://help.github.com/send-pull-requests/
