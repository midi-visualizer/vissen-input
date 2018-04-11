# frozen_string_literal: true

require 'forwardable'

module Vissen
  module Input
    # Subscription
    #
    # Whenever a callable object wants to receive messages from a broker it is
    # wrapped inside of a subscription. A subscription is a basic immutable
    # value object with a minimal api that keeps track of three things: a
    # Matcher, a callable handler and a numeric priority.
    class Subscription
      extend Forwardable

      attr_reader :priority

      def_delegator :@matcher, :match?, :match?
      def_delegator :@handler, :call, :handle

      # Initialize
      #
      # The handler must respond to #call.
      def initialize(matcher, handler, priority)
        @matcher  = matcher
        @handler  = handler
        @priority = priority

        freeze
      end
    end
  end
end
