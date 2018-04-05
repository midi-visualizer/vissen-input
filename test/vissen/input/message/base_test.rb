require 'test_helper'

describe Vissen::Input::Message::Base do
  subject { Vissen::Input::Message::Base }

  let(:channel_a) { rand 1...16 }
  let(:channel_b) { rand(1...15).tap { |v| break v + 1 if v >= channel_a } }
  let(:byte_a)    { rand 0..127 }
  let(:byte_b)    { rand(0..126).tap { |v| break v + 1 if v >= byte_a } }
  let(:data_a)    { [channel_a, byte_a, 0] }
  let(:data_b)    { [channel_b, byte_b, 0] }
  let(:timestamp) { Time.now.to_f }

  let(:msg)       { subject.new data_a, timestamp }

  describe '.matcher' do
    it 'returns a matcher that matches the status' do
      matcher = subject.matcher

      assert matcher.match? data_a
      assert matcher.match? data_b
    end

    it 'returns a matcher that matches only the given channel' do
      matcher = subject.matcher channel: channel_a

      assert matcher.match? data_a
      refute matcher.match? data_b
    end

    it 'returns a matcher that matches only the given number' do
      matcher = subject.matcher number: byte_a

      assert matcher.match? data_a
      refute matcher.match? data_b
    end

    it 'returns a matcher that does not match other data' do
      refute subject.matcher.match?([rand(1...16) << 4, 0, 0])
    end
  end

  describe '.create' do
    it 'creates a valid note message' do
      msg = subject.create(byte_a, 0, status: 0,
                                      channel: channel_a,
                                      timestamp: timestamp)

      assert_equal channel_a, msg.channel
      assert_equal data_a,    msg.data
    end

    it 'sets the value of unspecified bytes to 0' do
      msg = subject.create(byte_a, status: 0,
                                   channel: channel_a,
                                   timestamp: timestamp)

      assert_equal 0, msg.data[2]
    end

    it 'raises an error when given too many bytes' do
      assert_raises(ArgumentError) { subject.create 1, 2, 3 }
    end

    it 'raises an error for an invalid status' do
      assert_raises(RangeError) { subject.create status: 0x11 }
      assert_raises(RangeError) { subject.create status: 0x100 }
    end

    it 'raises an error for invalid channels' do
      assert_raises(RangeError) { subject.create channel: -1 }
      assert_raises(RangeError) { subject.create channel: 16 }
    end
  end

  describe '.factory' do
    it 'returns a factory that can build all of the known subclasses' do
      factory = subject.factory
      t       = timestamp

      # To get the channel mode message we need byte 1 to
      # equal or be greater than 120.
      b1 = ->(k) { k == Vissen::Input::Message::ChannelMode ? 120 : 0 }

      [
        Vissen::Input::Message::Aftertouch,
        Vissen::Input::Message::ChannelPressure,
        Vissen::Input::Message::ChannelMode,
        Vissen::Input::Message::ControlChange,
        Vissen::Input::Message::Note,
        Vissen::Input::Message::PitchBendChange,
        Vissen::Input::Message::ProgramChange
      ].each { |k| assert_kind_of k, factory.build([k::STATUS, b1[k], 0], t) }

      assert_kind_of Vissen::Input::Message::Unknown,
                     factory.build([0, 0, 0], timestamp)
    end
  end
end
