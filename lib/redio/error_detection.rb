module Redio
  module ErrorDetection
    # Redis Proxy that supports verification
    # Probably smarter just to extend redis or something
    class Node

      attr_reader :client

      def initialize(client)
        @client = client
      end

      # should be mmissing
      def execute(*args)
        client.send(*args)
      end

      def verify!
        error_detector.verify!
      end

    end

    def detect_error(value = nil)
      response = yield

      if response.respond_to?(:successes)
        response.successes.each do |client, response|
          error_detector.publish(client, value || response)
        end

        response = response.successes.values.last
      end

      super(response)
    end

  end
end
