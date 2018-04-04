module Vissen
  module Input
    module Message
      # Aftertouch
      #
      #
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
