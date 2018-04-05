module Vissen
  module Input
    module Message
      # Program Change
      #
      # From the MIDI Association:
      #   This message sent when the patch number changes.
      class ProgramChange < Base
        DATA_LENGTH = 2
        STATUS      = 0xC0

        def number
          data[1]
        end
      end
    end
  end
end
