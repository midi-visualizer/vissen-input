# frozen_string_literal: true

module Vissen
  module Input
    module Message
      # This is the base message implementaion. This class should never be used
      # directly, but rather be subclassed to create the various messages that
      # the system understands.
      #
      # The Base class keeps track of subclasses and can produce a message
      # factory for all the implementations that it knows about (see
      # `.factory`).
      class Base
        include Message
        
        # @see Message
        DATA_LENGTH = 3
        # @see Message
        STATUS      = 0

        # Checks message data consistency with the class default matcher.
        #
        # @return [true, false] true if the message data matches the class
        #   matcher.
        def valid?
          self.class.matcher.match? data
        end

        class << self
          # Returns a new instance of a Matcher, configured to match this
          # particular Message class. Subclasses of Base can utilize the same
          # functionality by simply redefining STATUS and, if necessary,
          # STATUS_MASK.
          #
          # By supplying the optional named arguments channel and number
          #
          # Raises a RangeError if the channel is given and is outside its valid
          # range of (0..15).
          # Raises a RangeError if number is given and is outside its valid
          # range of (0..127).
          #
          # @param  channel [nil, Integer] the channel to match, or nil to match
          #   all channels.
          # @param  number [nil, Integer] the second byte value to match, or nil
          #   to match all values.
          # @return [Matcher] the matcher that fulfills the requirements.
          def matcher(channel: nil, number: nil)
            return klass_matcher unless channel || number
            val, mask = status_value_and_mask channel

            if number
              raise RangeError unless (0...128).cover? number
              Matcher.new(self) { |d| (d[0] & mask) == val && d[1] == number }
            else
              Matcher.new(self) { |d| (d[0] & mask) == val }
            end
          end

          # Accessor for the class default matcher.
          #
          # @param  message [#to_a] the message or data to match.
          # @return [true, false] see `Matcher#match?`.
          def match?(message)
            matcher.match? message
          end

          # Creates a new factory with all the subclasses of base added to it as
          # matchers.
          #
          # @return [MessageFactory] a factory configured to build all
          #   subclasses of Base.
          def factory
            raise RuntimeError unless defined? @subclasses
            MessageFactory.new @subclasses.map(&:matcher)
          end

          # Alias to `#matcher` that swaps named arguments for positional ones.
          #
          # @see #matcher
          #
          # @param  (see #matcher)
          # @return (see #matcher)
          def [](channel, number = nil)
            matcher channel: channel, number: number
          end

          # Build a new instance of `Message::Base`, or a subclass, using more
          # intuitive arguments. Subclasses of Base can utilize the same
          # functionality by simply redefining `DATA_LENGTH` to correspond to
          # their message length.
          #
          # Note that status and channel are masked using the default masks, and
          # not the constants that may have been defined by a subclass.
          #
          # @param  bytes [Array<Integer>] the message data byte values.
          #   Unspecified values default to 0.
          # @param  status [Integer] the status to use for the new message.
          # @param  channel [Integer] the channel to use for the new message.
          # @param  timestamp [Float] the timestamp to use for the new message.
          # @return [Base] a new instance of this class.
          def create(*bytes, status: self::STATUS,
                     channel: 0,
                     timestamp: Time.now.to_f)
            raise ArgumentError if bytes.length >= self::DATA_LENGTH

            validate_status status
            validate_channel channel

            data = Array.new self::DATA_LENGTH, 0

            # Note: this line line must reference
            #       STATUS_MASK and not self::STATUS_MASK
            data[0] = (status & STATUS_MASK) + (channel & CHANNEL_MASK)

            # Copy the bytes
            bytes.each_with_index { |value, index| data[index + 1] = value }

            new data, timestamp
          end

          protected

          # Called automatically by inheriting classes.
          #
          # @param  subclass [Base] the inheriting class.
          # @return [nil]
          def inherited(subclass)
            (@subclasses ||= []) << subclass
            nil
          end

          # Helper method to validate a status value.
          #
          # @raise  [RangeError] if the status is outside its allowable range.
          #
          # @param  status [Integer] the status to validate.
          # @return [true] when the status is valid.
          def validate_status(status)
            raise RangeError unless (status & ~STATUS_MASK).zero?
            true
          end

          # Helper method to validate a channel value.
          #
          # @raise  [RangeError] if the channel is outside its allowable range.
          #
          # @param  channel [Integer] the channel to validate.
          # @return [true] when the channel is valid.
          def validate_channel(channel)
            raise RangeError unless (channel & ~CHANNEL_MASK).zero?
            true
          end

          # Creates a value and mask that can be used to match the first byte of
          # a message.
          #
          # == Usage
          # The following example illustrates how the value and mask are
          # intended to be used.
          #
          #   value, mask = status_value_and_mask
          #   0x42 & mask == value # => true if STATUS == 0x40
          #
          #   value, mask = status_value_and_mask 3
          #   0x42 & mask == value # => false since channel is 2
          #
          # @param  channel [Integer] the channel to match.
          # @return [Array<Integer>] a value and a mask.
          def status_value_and_mask(channel = nil)
            if channel
              validate_channel channel
              [(self::STATUS & self::STATUS_MASK) + (channel & CHANNEL_MASK),
               self::STATUS_MASK + CHANNEL_MASK]
            else
              [self::STATUS, self::STATUS_MASK]
            end
          end

          # The klass matcher is the most generic `Matcher` for the message
          # class and is cached to avoid duplication. By default the default
          # `Matcher` uses the value and mask returned by
          # `#status_value_and_mask` to match messages. Subclasses that need
          # different behaviour can pass a block to be forwarded directly to the
          # matcher (see Matcher.new).
          #
          # @param  block [Proc] the block that should be passed to
          #   `Matcher.new` when first creating the matcher.
          # @return [Matcher] a matcher that matches all messages of this type.
          def klass_matcher(&block)
            return @klass_matcher if defined?(@klass_matcher)

            unless block_given?
              val, mask = status_value_and_mask
              block = proc { |d| (d[0] & mask) == val }
            end

            @klass_matcher = Matcher.new(self, &block)
          end
        end
      end
    end
  end
end
