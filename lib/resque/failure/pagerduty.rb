module Resque
  module Failure
    # A Resque failure backend that handles exceptions by triggering
    # incidents in the Pagerduty API
    class Pagerduty < Base
    end
  end
end
