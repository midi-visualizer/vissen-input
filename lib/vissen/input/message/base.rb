module Vissen
  module Input
    module Message
      # Base
      #
      # Base message implementaion. This class should never be used directly,
      # but rather be subclassed to create the various messages that the system
      # understands.
      #
      # The Base class keeps track of subclasses and can produce a message
      # factory for all the implementations that it knows about.
      class Base
        include Message

        DATA_LENGTH = 3
        STATUS      = 0

        def valid?
          self.class.matcher.match? data
        end

        class << self
          def inherited(subclass)
            (@subclasses ||= []) << subclass
          end

          # Matcher
          #
          # Returns a new instance of a Matcher, configured to match this
          # particular Message class. Subclasses of Base can utilize the same
          # functionality by simply redefining STATUS and, if necessary,
          # STATUS_MASK.
          #
          # By supplying the optional named arguments channel and number
          def matcher(channel: nil, number: nil)
            return @matcher if defined?(@matcher) && !channel && !number
            val, mask = status_value_and_mask channel

            if number
              raise RangeError unless (0...128).cover? number
              Matcher.new(self) { |d| (d[0] & mask) == val && d[1] == number }
            else
              Matcher.new(self) { |d| (d[0] & mask) == val }.tap do |m|
                # Cache the matcher if both channel and number are nil
                @matcher = m unless channel || number
              end
            end
          end

          # Factory
          #
          # Returns a new factory with all the subclasses of base added to it as
          # matchers.
          def factory
            raise RuntimeError unless defined? @subclasses
            MessageFactory.new @subclasses.map(&:matcher)
          end

          # [] (Matcher)
          #
          # Alias to #matcher that swaps positional arguments for named ones.
          def [](channel, number = nil)
            matcher channel: channel, number: number
          end

          # Create
          #
          # Build a new instance of the Message::Base, or subclass, using more
          # intuitive arguments. Subclasses of Base can utilize the same
          # functionality by simply redefining DATA_LENGTH to correspond to
          # their message length.
          #
          # Note that status and channel are masked using the default masks, and
          # not the constants that may have been defined by a subclass.
          def create(*bytes, status: 0, channel: 0, timestamp: Time.now.to_f)
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

          def validate_status(status)
            raise RangeError unless (status & ~STATUS_MASK).zero?
          end

          def validate_channel(channel)
            raise RangeError unless (channel & ~CHANNEL_MASK).zero?
          end

          def status_value_and_mask(channel = nil)
            if channel
              validate_channel channel
              [(self::STATUS & self::STATUS_MASK) + (channel & CHANNEL_MASK),
               self::STATUS_MASK + CHANNEL_MASK]
            else
              [self::STATUS, self::STATUS_MASK]
            end
          end
        end
      end
    end
  end
end
