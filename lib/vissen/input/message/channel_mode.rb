module Vissen
  module Input
    module Message
      # Program Change
      #
      # From the MIDI Association:
      #   This the same code as the Control Change (above), but implements Mode
      #   control and special message by using reserved controller numbers
      #   120-127. The commands are:
      #
      #   - All Sound Off (120)
      #       When All Sound Off is received all oscillators will turn off, and
      #       their volume envelopes are set to zero as soon as possible.
      #   - Reset All Controllers (121)
      #       When Reset All Controllers is received, all controller values are
      #       reset to their default values.
      #   - Local Control (122)
      #       When Local Control is Off, all devices on a given channel will
      #       respond only to data received over MIDI. Played data, etc. will be
      #       ignored. Local Control On restores the functions of the normal
      #       controllers.
      #   - All Notes Off (123..127)
      #       When an All Notes Off is received, all oscillators will turn off.
      #
      class ChannelMode < Base
        STATUS = 0xB0

        def number
          data[1]
        end

        class << self
          # Matcher
          #
          # The channel mode message is special in that it is only valid when
          # the second byte takes values equal to or greather than 120. We
          # therefore need to override Base.matcher.
          def matcher
            Matcher.new(self) do |d|
              (d[0] & STATUS_MASK) == STATUS && d[1] >= 120
            end
          end
        end
      end
    end
  end
end
