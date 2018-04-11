# frozen_string_literal: true

module Vissen
  module Input
    module Message
      # From the MIDI Association:
      #   Note On event.
      #   This message is sent when a note is depressed (start).
      #
      #   Note Off event.
      #   This message is sent when a note is released (ended).
      class Note < Base
        STATUS_MASK = 0xE0
        STATUS      = 0x80
        NOTE_ON     = 0x10
        NOTE_OFF    = 0x00

        # @return [Integer] the note value.
        def note
          data[1]
        end

        # @return [Integer] the velocity value.
        def velocity
          data[2]
        end

        # @return [true, false] true if the note was released.
        def off?
          (data[0] & NOTE_ON).zero?
        end

        # @return [true, false] true if the note was depressed.
        def on?
          !off?
        end

        class << self
          # @param  bytes (see Base.create)
          # @param  on [true, false] true if the note should be depressed,
          #   otherwise false.
          # @param  args (see Base.create)
          # @return [Note]
          def create(*bytes, on: true, **args)
            super(*bytes, status: STATUS + (on ? NOTE_ON : NOTE_OFF), **args)
          end
        end
      end
    end
  end
end
