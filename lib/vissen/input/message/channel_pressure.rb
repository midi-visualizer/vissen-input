# frozen_string_literal: true

module Vissen
  module Input
    module Message
      # From the MIDI Association:
      #
      # > Channel Pressure (After-touch). This message is most often sent by
      # > pressing down on the key after it "bottoms out". This message is
      # > different from polyphonic after-touch. Use this message to send the
      # > single greatest pressure value (of all the current depressed keys)
      class ChannelPressure < Base
        # @see Message
        DATA_LENGTH = 2
        # @see Message
        STATUS      = 0xD0

        # @return [Integer] the pressure value.
        def pressure
          data[1]
        end
      end
    end
  end
end
