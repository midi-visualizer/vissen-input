module Vissen
  module Input
    module Message
      # Base
      #
      #
      class Base
        include Message
        
        DATA_LENGTH = 3
        STATUS      = 0
        
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
            if channel
              validate_channel channel
              mask = self::STATUS_MASK + CHANNEL_MASK
              val  = (self::STATUS & self::STATUS_MASK) +
                       (channel & CHANNEL_MASK)
            else
              mask = self::STATUS_MASK
              val  = self::STATUS
            end
            
            if number
              raise RangeError unless (0...128).include? number
              Matcher.new(self) { |d| (d[0] & mask) == val && d[1] == number }
            else
              Matcher.new(self) { |d| (d[0] & mask) == val }
            end
          end
          
          # Factory
          #
          # Returns a new factory with all the subclasses of base added to it as
          # matchers.
          def factory
            MessageFactory.new(@subclasses.map { |k| k.matcher })
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
            raise ArgumentError unless bytes.length >= self::DATA_LENGTH - 1
            
            validate_channel channel
            
            # Note: this line line must reference
            #       STATUS_MASK and not self::STATUS_MASK
            data = [(status & STATUS_MASK) + (channel & CHANNEL_MASK), *bytes]
            new data, timestamp
          end
          
          protected
          
          def validate_channel(channel)
            raise RangeError unless (0...16).include? channel
          end
        end
      end
    end
  end
end