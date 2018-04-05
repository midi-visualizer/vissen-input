module Vissen
  module Input
    module Message
      # Channel Pressure
      #
      # From the MIDI Association:
      #   Channel Pressure (After-touch). This message is most often sent by
      #   pressing down on the key after it "bottoms out". This message is
      #   different from polyphonic after-touch. Use this message to send the
      #   single greatest pressure value (of all the current depressed keys)
      class ChannelPressure < Base
        STATUS      = 0xD0
        DATA_LENGTH = 2

        def value
          data[1]
        end
      end
    end
  end
end
