# frozen_string_literal: true

module Vissen
  module Input
    # Message broker that consumes a stream of messages and exposes a simple
    # subscription interface.
    #
    # == Usage
    # This example subscribes to note messages on channel 1 and calls the
    # fictitious method play when a matching message is published and processed.
    #
    #   broker = Broker.new
    #   broker.subscribe Message::Note[1], priority: 1 do |message|
    #     play message.note
    #   end
    #
    #   message = Message::Note.create 42, channel: 1
    #   broker.publish message
    #   broker.run_once
    #
    # The next example sets up two different priority listeners, one of which
    # blocks the other for some messages.
    #
    #   broker = Broker.new
    #   broker.subscribe Message::Note[1], priority: 1 do |message|
    #     play message.note
    #   end
    #
    #   broker.subscribe Message::Note[1], priority: 2 do |message, ctrl|
    #     ctrl.stop! if message.note % 2 == 0
    #   end
    #
    class Broker
      def initialize
        @subscriptions = []
        @message_queue = Queue.new
      end

      # Register a callback for the broker to run when a message matched by the
      # given matcher is published.
      #
      # By specifying a priority a subscriber added after another can still be
      # handled at an earlier time. The handler can either be specified as an
      # object responding to `#call` or as a block.
      #
      # @param  matcher [#match?] the matcher that will be used to filter
      #   messeges.
      # @param  handler [#call] the handler that will be called when a matching
      #   message is published. Mandatory unless a block is given.
      # @param  priority [Integer] the priority determines when the subscription
      #   will be matched against a published message in relation to other
      #   subscriptions.
      # @return [Subscription] the new subscription object.
      def subscribe(matcher, handler = nil, priority: 0, &block)
        if block_given?
          raise ArgumentError if handler
          handler = block
        else
          raise ArgumentError unless handler
        end

        insert_subscription Subscription.new(matcher, handler, priority)
      end

      # Removes the given subscription.
      #
      # @param  subscription [Subscription] the subscription to cancel.
      # @return [Subscription, nil] the subscription that was cancelled, or nil
      #   if the subscription was not found.
      def unsubscribe(subscription)
        @subscriptions.delete subscription
      end

      # Insert a new message into the message queue. The message is handled at a
      # later time in `#run_once`.
      #
      # @param  message [Message] the message(s) to handle.
      def publish(*message)
        message.each { |m| @message_queue.push m }
      end

      # Takes one message from the message queue and handles it.
      #
      # @return [true, false] true if the message_queue contained a message,
      #   otherwise false.
      def run_once
        return false if @message_queue.empty?
        ctrl = PropagationControl.new
        call @message_queue.shift, ctrl
        true
      end

      # Processes one message. By design, implementing this method allows for
      # multiple brokers being chained.
      #
      # @param  message [Message] the message to match against the
      #   subscriptions.
      # @return [nil]
      def call(message, ctrl)
        # TODO: Remap the message if needed.
        @subscriptions.each do |subscription|
          break if ctrl.stop?(subscription.priority)
          next unless subscription.match? message

          subscription.handle message, ctrl
        end
        nil
      end

      private

      # Insert of append a new subscription to the list. The subscription will
      # be placed before the first subscription that is found to have a lower
      # priority, or last.
      #
      # @param  subscription [Subscription] the subscription to add.
      # @return [Subscription] the subscription that was added.
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

      # Internal class used by the `Broker` to control the propagation of a
      # message and provide a control surface for subscription handlers,
      # allowing them to stop the propagation at priorites lower than (not equal
      # to) their own.
      #
      # == Usage
      # The following example uses a propagation control object to stop
      # propagation at priority 1. Note that `#stop?` must be called for each
      # message before `#stop!` to ensure that the correct priority is set.
      #
      #   ctrl = PropagationControl.new
      #   ctrl.stop? 2 # => false
      #   ctrl.stop? 1 # => false
      #
      #   ctrl.stop!
      #
      #   ctrl.stop? 1 # => false
      #   ctrl.stop? 0 # => true
      #
      class PropagationControl
        def initialize
          @stop_at_priority = -1
          @current_priority = 0
        end

        # @param  priority [Integer] the priority to check out stopping
        #   condition against.
        # @return [true, false] whether to stop or not.
        def stop?(priority)
          return true if priority < @stop_at_priority

          @current_priority = priority
          false
        end

        # Sets the priority stopping threshold.
        #
        # @return [nil]
        def stop!
          @stop_at_priority = @current_priority
          nil
        end
      end
    end
  end
end
