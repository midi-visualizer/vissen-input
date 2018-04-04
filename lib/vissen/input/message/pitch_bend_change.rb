module Vissen
  module Input
    module Message
      # Pitch Bend Change
      #
      #
      class PitchBendChange < Base
        STATUS       = 0xE0
        CENTER_VALUE = 0x2000
      
        def raw
          (data[2] << 7) + data[1] - CENTER_VALUE
        end
        
        def value
          raw.to_f / CENTER_VALUE
        end
      end
    end
  end
end
