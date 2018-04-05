module Vissen
  module Input
    module Message
      # Note
      #
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
        
        def note
          data[1]
        end
        
        def velocity
          data[2]
        end
        
        def off?
          (data[0] & NOTE_ON) == 0
        end
        
        def on?
          !off?
        end
        
        class << self
          # Create
          #
          # Returns a new instance of a Note message.
          def create(*bytes, on: true, **args)
            super(*bytes, status: STATUS + (on ? NOTE_ON : NOTE_OFF), **args)
          end
        end
      end
    end
  end
end
