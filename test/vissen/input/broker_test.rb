# frozen_string_literal: true

require 'test_helper'

describe Vissen::Input::Broker do
  subject { Vissen::Input::Broker }

  let(:msg_klass) { Vissen::Input::Message::Note }
  let(:msg)       { msg_klass.create }
  let(:matcher)   { msg_klass.matcher }
  let(:handler) do
    proc do |msg|
      assert_kind_of Vissen::Input::Message, msg
      @called = true
    end
  end
  let(:factory)   { Vissen::Input::Message::Base.factory }
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
      broker.publish data: [0xE0, 0, 0], timestamp: 0.0
      broker.run_once

      refute @called
    end

    it 'accpets a hash' do
      broker.publish msg.to_h
      broker.run_once

      assert @called
    end

    it 'publishes multiple messages' do
      broker.publish(msg, msg)
      broker.run_once

      assert @called
      @called = false

      broker.run_once
      assert @called
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

    it 'stops propagation at lower priorities' do
      counter = 0

      broker.subscribe(matcher, priority: 1) do |_, ctrl|
        counter += 1
        ctrl.stop!
      end

      broker.subscribe(matcher, priority: 1) do
        counter += 1
      end

      broker.subscribe(matcher) do
        assert false
      end

      broker.publish msg
      broker.run_once
      assert_equal 2, counter
    end

    describe 'allocation' do
      before { GC.disable }
      after  { GC.enable }

      it 'allocates a new message when a subscription match' do
        broker.subscribe matcher, handler

        count_before = ObjectSpace.each_object(Vissen::Input::Message).count

        100.times { broker.publish(data: [0x90, 0, 0], timestamp: 0.0) }

        count_mid = ObjectSpace.each_object(Vissen::Input::Message).count
        assert_equal count_before, count_mid

        100.times { broker.run_once }

        count_after = ObjectSpace.each_object(Vissen::Input::Message).count
        assert_equal count_before + 100, count_after
      end

      it 'does not allocate message objects when no subscriptions match' do
        broker.subscribe(matcher) { assert false }

        count_before = ObjectSpace.each_object(Vissen::Input::Message).count

        100.times { broker.publish(data: [0xE0, 0, 0], timestamp: 0.0) }
        100.times { broker.run_once }

        count_after = ObjectSpace.each_object(Vissen::Input::Message).count
        assert_equal count_before, count_after
      end

      it 'only allocates on new instance' do
        broker.subscribe matcher, handler
        broker.subscribe matcher, handler
        broker.publish(data: [0x90, 0, 0], timestamp: 0.0)

        count_before = ObjectSpace.each_object(Vissen::Input::Message).count
        broker.run_once
        count_after = ObjectSpace.each_object(Vissen::Input::Message).count

        assert_equal count_before + 1, count_after
      end
    end
  end
end
