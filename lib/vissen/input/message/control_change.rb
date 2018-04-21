# frozen_string_literal: true

module Vissen
  module Input
    module Message
      # From the MIDI Association:
      #
      # > This message is sent when a controller value changes. Controllers
      # > include devices such as pedals and levers. Controller numbers 120-127
      # > are reserved as "Channel Mode Messages".
      class ControlChange < Base
        # @see Message
        STATUS = 0xB0

        # @return [Integer] the control number.
        def number
          data[1]
        end

        # @return [Integer] the control value.
        def value
          data[2]
        end

        class << self
          protected

          # The control change message is special in that it is only valid when
          # the second byte takes values lower than 120. We therefore need to
          # override `Base.klass_matcher`.
          #
          # FIXME: other matchers created may not be correct.
          def klass_matcher
            super do |d|
              (d[0] & STATUS_MASK) == STATUS && d[1] < 120
            end
          end
        end
      end
    end
  end
end
