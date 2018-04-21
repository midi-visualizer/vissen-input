# frozen_string_literal: true

module Vissen
  module Input
    module Message
      # From the MIDI Association:
      #
      # > Polyphonic Key Pressure (Aftertouch). This message is most often sent
      # > by pressing down on the key after it "bottoms out".
      class Aftertouch < Base
        # @see Message
        STATUS = 0xA0

        # @return [Integer] the note value.
        def note
          data[1]
        end

        # @return [Integer] the preassure value.
        def preassure
          data[2]
        end
      end
    end
  end
end
