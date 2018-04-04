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
          
          def matcher
            Matcher.new(self) { |d| (d[0] & self::STATUS_MASK) == self::STATUS }
          end
          
          def create(*bytes, status: 0, channel: 0, timestamp: Time.now.to_f)
            raise ArgumentError unless bytes.length >= self::DATA_LENGTH - 1
            
            # Note: this line line must reference
            #       STATUS_MASK and not self:STATUS_MASK
            data = [(status & STATUS_MASK) + (channel & CHANNEL_MASK), *bytes]
            new data, timestamp
          end
          
          # Create a more specific matcher that also matches the specified
          # channel and optionally the value of the second byte.
          def [](channel, number = nil)
            raise RangeError unless (0...16).include? channel
            
            mask = self::STATUS_MASK + CHANNEL_MASK
            val  = (self::STATUS & self::STATUS_MASK) + (channel & CHANNEL_MASK)
            
            if number
              raise RangeError unless (0...128).include? number
              Matcher.new(self) { |d| (d[0] & mask) == val && d[1] == number }
            else
              Matcher.new(self) { |d| (d[0] & mask) == val }
            end
          end
        end
      end
    end
  end
end