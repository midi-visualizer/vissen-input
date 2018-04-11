# frozen_string_literal: true

module Vissen
  module Input
    # Broker
    #
    #
    class Broker
      def initialize
        @subscriptions = []
        @message_queue = Queue.new
      end

      # Subscribe
      #
      # Register a callback for the broker to run when a message matched by the
      # given matcher is published. By specifying a priority a subscriber added
      # after another can still be handled at an earlier time.
      def subscribe(matcher, handler = nil, priority: 0, &block)
        if block_given?
          raise ArgumentError if handler
          handler = block
        else
          raise ArgumentError unless handler
        end

        insert_subscription Subscription.new(matcher, handler, priority)
      end

      # Unsubscribe
      #
      # Removes the given subscription.
      def unsubscribe(subscription)
        @subscriptions.delete subscription
      end

      # Publish
      #
      # Insert a new message into the message queue. The message is handled at a
      # later time in #run_once.
      def publish(message)
        @message_queue.push message
      end

      # Run Once
      #
      # Takes one message from the message queue and handles it.
      def run_once
        return false if @message_queue.empty?
        call @message_queue.shift
        true
      end

      # Call
      #
      # Process one message. By design, implementing this method allows for
      # multiple brokers being chained.
      def call(message)
        # TODO: Remap the message if needed.
        @subscriptions.each do |subscription|
          next unless subscription.match? message

          subscription.handle message
        end
      end

      private

      def insert_subscription(subscription)
        @subscriptions.each_with_index do |other, index|
          if other.priority < subscription.priority
            @subscriptions.insert index, subscription
            return subscription
          end
        end

        @subscriptions.push subscription
        subscription
      end
    end
  end
end
