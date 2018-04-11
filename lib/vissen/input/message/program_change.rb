# frozen_string_literal: true

module Vissen
  module Input
    module Message
      # From the MIDI Association:
      #   This message sent when the patch number changes.
      class ProgramChange < Base
        DATA_LENGTH = 2
        STATUS      = 0xC0

        # @return [Integer] the program number.
        def number
          data[1]
        end
      end
    end
  end
end
