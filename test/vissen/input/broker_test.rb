# frozen_string_literal: true

require 'test_helper'

describe Vissen::Input::Broker do
  subject { Vissen::Input::Broker }

  let(:msg_klass) { Vissen::Input::Message::Note }
  let(:msg)       { msg_klass.create }
  let(:matcher)   { msg_klass.matcher }
  let(:handler)   { proc { @called = true } }
  let(:broker)    { subject.new }

  before { @called = false }

  describe '#subscribe' do
    it 'returns the subscription' do
      subscription = broker.subscribe matcher, handler

      assert_kind_of Vissen::Input::Subscription, subscription
    end

    it 'sets the priority to 0 by default' do
      subscription = broker.subscribe matcher, handler
      assert_equal 0, subscription.priority
    end

    it 'accepts an optional priority' do
      subscription = broker.subscribe matcher, handler, priority: 1
      assert_equal 1, subscription.priority
    end

    it 'raises an ArgumentError when given both a handler and a block' do
      assert_raises(ArgumentError) do
        broker.subscribe(matcher, handler) {}
      end
    end

    it 'raises an ArgumentError when not given a handler or a block' do
      assert_raises(ArgumentError) { broker.subscribe matcher }
    end
  end

  describe '#unsubscribe' do
    it 'removes the subscription' do
      subscription = broker.subscribe matcher, handler
      broker.unsubscribe subscription

      broker.publish msg
      broker.run_once
      refute @called
    end
  end

  describe '#publish' do
    before { broker.subscribe matcher, handler }

    it 'does not call the message handler' do
      broker.publish msg
      refute @called
    end

    it 'enques the matching handler' do
      broker.publish msg
      broker.run_once

      assert @called
    end

    it 'does not send other messages to the handler' do
      broker.publish [0xE0, 0, 0]
      broker.run_once

      refute @called
    end
  end

  describe '#run_once' do
    it 'calls the handlers in the correct order' do
      counter = 0

      broker.subscribe(matcher) do
        assert_equal 1, counter
        counter += 1
      end

      broker.subscribe(matcher) do
        assert_equal 2, counter
        counter += 1
      end

      broker.subscribe(matcher, priority: 1) do
        assert_equal 0, counter
        counter += 1
      end

      broker.publish msg
      broker.run_once
      assert_equal 3, counter
    end

    it 'forwards the message to another broker' do
      other = subject.new
      other.subscribe(matcher, handler)

      broker.subscribe matcher, other
      broker.publish msg

      broker.run_once
      assert @called
    end
  end
end
