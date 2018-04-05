require 'forwardable'

module Vissen
  module Input
    # Message
    #
    # This module implements the minimal interface for an input message. All
    # message classes must _include_ this module to be compatible with the input
    # matching engine.
    #
    # All Vissen Input Messages must be representable by one to three bytes.
    # This stems from the tight connection with the MIDI protocol. Each message
    # must also store a timestamp from when the input arrived to the system.
    #
    # The individual message implementations are based off the information given
    # on the [midi association website](https://www.midi.org/specifications/item/table-1-summary-of-midi-message).
    #
    module Message
      STATUS_MASK  = 0xF0
      CHANNEL_MASK = 0x0F
      DATA_LENGTH  = 1
      
      attr_reader :data, :timestamp
      
      # Allow a message to pass for the raw byte array
      alias to_a data
      
      def initialize(data, timestamp)
        raise TypeError unless data.length >= self.class::DATA_LENGTH

        @data      = data.freeze
        @timestamp = timestamp.freeze
      end
      
      def status
        @data[0] & self.class::STATUS_MASK
      end
      
      def channel
        @data[0] & self.class::CHANNEL_MASK
      end
    end
  end
end