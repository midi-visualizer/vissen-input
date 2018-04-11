# frozen_string_literal: true

require 'forwardable'

module Vissen
  module Input
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
    # Terminology
    # -----------
    # The first (and mandatory) byte of the data byte array is referred to as
    # the message status. Since this byte also include channel information the
    # term _status_ is, howerver, sometimes also used to name only the upper
    # nibble of the status field.
    module Message
      STATUS_MASK  = 0xF0
      CHANNEL_MASK = 0x0F
      DATA_LENGTH  = 1

      # @return [Array<Integer>]
      attr_reader :data

      # @return [Float]
      attr_reader :timestamp

      # Allow a message to pass for the raw byte array
      alias to_a data

      # @param  data [Array<Integer>] the raw message data.
      # @param  timestamp [Float] the time that the message was received.
      def initialize(data, timestamp)
        raise TypeError unless data.length >= self.class::DATA_LENGTH

        @data      = data.freeze
        @timestamp = timestamp.freeze
      end

      # The default for messages is to always be valid. Message implementations
      # can override this behaviour.
      #
      # @return [true]
      def valid?
        true
      end

      # @return [Integer] the message status.
      def status
        @data[0] & self.class::STATUS_MASK
      end

      # @return [Integer] the message channel.
      def channel
        @data[0] & self.class::CHANNEL_MASK
      end
    end
  end
end
