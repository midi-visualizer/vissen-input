# frozen_string_literal: true

module Vissen
  module Input
    # The facatory takes raw input messages and builds matching objects around
    # them. It stores a list of input matchers that it knows about.
    #
    # If an array of matchers is passed to the constructor the MessageFactory
    # will freeze itself to create an immutable factory.
    #
    # TODO: Sort the matchers on input frequency for performance?
    #
    # == Usage
    # The following example sets up a factory to build ControlChange messages.
    #
    #   matcher = Message::ControlChange.matcher
    #   factory = MessageFactory.new [matcher]
    #
    #   factory.build [0xC0, 3, 42], 0.0 # => Message::ControlChange
    #   factory.build [0xB0, 0, 0], 0.0  # => Message::Unknown
    #
    class MessageFactory
      # @param  matchers [nil, Array<Matcher>] the matchers to use when building
      #   messages. If provided the factory will be frozen after creation.
      def initialize(matchers = nil)
        @lookup_table = Array.new(16) { [] }
        @matchers     = []

        return unless matchers

        matchers.each { |m| add_matcher m }
        freeze
      end

      # Prevents any more matchers from being added.
      #
      # @return [self]
      def freeze
        @matchers.freeze
        super
      end

      # Inserts another matcher to the list of known input data matchers.
      #
      # @param  matcher [Matcher] the matcher to add.
      # @return [self]
      def add_matcher(matcher)
        raise TypeError unless matcher.is_a? Matcher
        @matchers << matcher
        self
      end

      # Creates a new Message object by matching the data against the stored
      # message classes.
      #
      # @param  obj [#to_a] the data object to build the new message arround.
      # @param  timestamp [Float] the time that the message was first received.
      # @return [Message]
      def build(obj, timestamp)
        data  = obj.to_a
        klass =
          if obj.is_a?(Message) && obj.valid?
            return obj if obj.timestamp == timestamp
            obj.class
          else
            matcher = lookup data
            matcher ? matcher.klass : Message::Unknown
          end

        klass.new data, timestamp
      end

      private

      def lookup(data)
        status  = data[0] >> 4
        entry   = @lookup_table[status]
        matcher = entry&.find { |m| m.match? data }

        unless matcher
          matcher = @matchers.find { |m| m.match? data }
          add_to_lookup matcher, data if matcher
        end

        matcher
      end

      def add_to_lookup(matcher, data)
        status = data[0] >> 4
        @lookup_table[status] << matcher
      end
    end
  end
end
