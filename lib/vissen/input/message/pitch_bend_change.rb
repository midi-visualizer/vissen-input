# frozen_string_literal: true

module Vissen
  module Input
    module Message
      # Pitch Bend Change
      #
      # From the MIDI Association:
      #   This message is sent to indicate a change in the pitch bender (wheel
      #   or lever, typically). The pitch bender is measured by a fourteen bit
      #   value. Center (no pitch change) is 2000H. Sensitivity is a function of
      #   the receiver, but may be set using RPN 0.
      class PitchBendChange < Base
        STATUS       = 0xE0
        CENTER_VALUE = 0x2000

        def raw
          (data[2] << 7) + data[1] - CENTER_VALUE
        end

        def value
          raw.to_f / CENTER_VALUE
        end
      end
    end
  end
end
