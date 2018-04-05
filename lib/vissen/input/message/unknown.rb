module Vissen
  module Input
    module Message
      # Unknown
      #
      # The unknown message type is not a subclass of Base since it is never
      # meant to be used directly. It is instead expected to be created by the
      # MessageFactory whenever the incomming data does not match any known
      # matcher.
      class Unknown
        include Message
      end
    end
  end
end
