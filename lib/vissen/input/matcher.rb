module Vissen
  module Input
    # Matcher
    #
    # The job of an input matcher is to match a raw message to a message class.
    class Matcher
      attr_reader :klass

      def initialize(message_klass, &proc)
        raise TypeError unless message_klass <= Message

        @klass   = message_klass
        @matcher = proc

        freeze
      end

      # Match?
      #
      # The given object must respond to #to_a.
      def match?(obj)
        data = obj.to_a

        return false unless data.length >= @klass::DATA_LENGTH
        @matcher.call data
      end
    end
  end
end
