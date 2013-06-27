module Resque
  module Failure
    class GeneratesPagerdutyDesc
      MAX_LENGTH = 120
      OMISSION = '...'

      def initialize(exception, payload)
        @exception = exception
        @payload = payload
      end

      def execute
        if full_message.length > MAX_LENGTH
          full_message.slice(0, MAX_LENGTH - OMISSION.length) + OMISSION
        else
          full_message
        end
      end

      def self.execute(exception, payload)
        new(exception, payload).execute
      end

      private

      def full_message
        @full_message ||= "#{@exception.class} in #{@payload['class']}: #{@exception.message}"
      end

    end
  end
end
