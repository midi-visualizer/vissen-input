# frozen_string_literal: true

module Vissen
  module Input
    module Message
      # Control Change
      #
      # From the MIDI Association:
      #   This message is sent when a controller value changes. Controllers
      #   include devices such as pedals and levers. Controller numbers 120-127
      #   are reserved as "Channel Mode Messages".
      class ControlChange < Base
        STATUS = 0xB0

        def number
          data[1]
        end

        def value
          data[2]
        end

        class << self
          # Matcher
          #
          # The control change message is special in that it is only valid when
          # the second byte takes values lower than 120. We therefore need to
          # override Base.matcher.
          def matcher
            Matcher.new(self) do |d|
              (d[0] & STATUS_MASK) == STATUS && d[1] < 120
            end
          end
        end
      end
    end
  end
end
