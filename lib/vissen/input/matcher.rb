# frozen_string_literal: true

module Vissen
  module Input
    # The job of an input matcher is to match a raw message with a message
    # class.
    #
    # == Usage
    # In the following example a matcher is setup to match aftertouch messages
    # (on channel 0). Only data arrays of the correct length and content causes
    # `#match?` to return true
    #
    #   matcher = Matcher.new(Message::Aftertouch) { |d| d[0] == 0xA0 }
    #
    #   matcher.match? [0xB0, 0, 0] # => false
    #   matcher.match? [0xA0, 0]    # => false
    #   matcher.match? [0xA0, 0, 0] # => true
    #
    class Matcher
      # @return [Message] the message class responsible for the messages that
      #   this matcher matches.
      attr_reader :klass

      # @param message_klass [Message] the message class that should be used to
      #   parse the data that this matcher matches. The class constant
      #   `DATA_LENGTH` will be used to verify that the data has the correct
      #   length.
      # @param proc [#call] the block that will be called to match messages.
      def initialize(message_klass, &proc)
        raise TypeError unless message_klass <= Message

        @klass = message_klass
        @rule  = proc

        freeze
      end

      # Match either a byte array or a `Message` against the rule stored in the
      # matcher.
      #
      # @raise  [KeyError] if `obj` is a `Hash` but does not include the `:data`
      #   key.
      #
      # @param  obj [Hash, #to_a] the message data to match.
      # @return [true, false] true if the data matches.
      def match?(obj)
        data = obj.is_a?(Hash) ? obj.fetch(:data) : obj.to_a

        return false unless data.length >= @klass::DATA_LENGTH
        @rule.call data
      end
    end
  end
end
