module Vissen
  module Input
    module Message
      # Aftertouch
      #
      # From the MIDI Association:
      #   Polyphonic Key Pressure (Aftertouch). This message is most often sent
      #   by pressing down on the key after it "bottoms out".
      class Aftertouch < Base
        STATUS = 0xA0
      
        def note
          data[1]
        end
      
        def preassure
          data[2]
        end
      end
    end
  end
end
