# frozen_string_literal: true

require 'forwardable'

module Vissen
  module Input
    # Whenever a callable object wants to receive messages from a broker it is
    # wrapped inside of a subscription. A subscription is a basic immutable
    # value object with a minimal api that keeps track of three things: a
    # Matcher, a callable handler and a numeric priority.
    class Subscription
      extend Forwardable

      # @return [Integer] the subscription priority.
      attr_reader :priority

      # @!method match?(message)
      # This method is forwarded to `Message#match?`.
      #
      # @return [true, false] (see Matcher#match?).
      def_delegator :@matcher, :match?, :match?

      # @!method handle(message)
      # Calls the registered handler with the given message.
      #
      # @return (see Matcher#match?)
      def_delegator :@handler, :call, :handle

      # @param  matcher [#match?] the matcher to use when filtering messages.
      # @param  handler [#call] the target of the subscription.
      # @param  priority [Integer] the priority of the subscription relative
      #   other subscriptions.
      def initialize(matcher, handler, priority)
        @matcher  = matcher
        @handler  = handler
        @priority = priority

        freeze
      end
    end
  end
end
