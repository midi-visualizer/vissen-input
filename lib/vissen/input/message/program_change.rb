module Vissen
  module Input
    module Message
      # Program Change
      #
      #
      class ProgramChange < Base
        DATA_LENGTH = 2
        STATUS      = 0xC0
      
        def number
          data[1]
        end
      end
    end
  end
end
