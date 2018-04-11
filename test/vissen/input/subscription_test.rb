# frozen_string_literal: true

require 'test_helper'

describe Vissen::Input::Subscription do
  subject { Vissen::Input::Subscription }

  let(:msg_klass)    { Vissen::Input::Message::Note }
  let(:msg)          { msg_klass.create }
  let(:matcher)      { msg_klass.matcher }
  let(:handler)      { Minitest::Mock.new }
  let(:subscription) { subject.new matcher, handler, 0 }

  describe '.new' do
    it 'has a priority' do
      assert_equal 0, subscription.priority
    end

    it 'is frozen' do
      assert subscription.frozen?
    end
  end

  describe '#match?' do
    it 'returns true for a matching data array' do
      assert subscription.match?([0x90, 0, 0])
    end

    it 'returns true for a matching message instance' do
      assert subscription.match?(msg)
    end

    it 'returns false for a different data array' do
      refute subscription.match?([0xE0, 0, 0])
    end

    it 'returns false for a matching message instance' do
      msg = Vissen::Input::Message::ProgramChange.create
      refute subscription.match?(msg)
    end
  end

  describe '#handle' do
    it 'calls #call on the handler' do
      handler.expect(:call, nil, [msg])
      subscription.handle msg
      handler.verify
    end
  end
end
