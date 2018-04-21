# frozen_string_literal: true

module Vissen
  module Input
    module Message
      # From the MIDI Association:
      #
      # > This message is sent to indicate a change in the pitch bender (wheel
      # > or lever, typically). The pitch bender is measured by a fourteen bit
      # > value. Center (no pitch change) is 2000H. Sensitivity is a function of
      # > the receiver, but may be set using RPN 0.
      class PitchBendChange < Base
        # @see Message
        STATUS       = 0xE0

        # Center value is defined as the the offset that should be removed from
        # the 14 bit pitch bend value to center it around zero.
        CENTER_VALUE = 0x2000

        # @return [Integer] the integer pitch bend value.
        def raw
          (data[2] << 7) + data[1] - CENTER_VALUE
        end

        # @return [Float] the pitch bend value normalized to the range (-1..1).
        def value
          raw.to_f / CENTER_VALUE
        end

        class << self
          # TODO: Check the range on value.
          #
          # @param  value [Float] the pitch bend value in the range (-1..1).
          # @param  args (see Base.create)
          # @return [PitchBendChange]
          def create(value = 0.0, **args)
            bin_value = (value.to_f * CENTER_VALUE).round + CENTER_VALUE

            super(bin_value & 0xFF, bin_value >> 7, **args)
          end
        end
      end
    end
  end
end
