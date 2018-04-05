require 'test_helper'

describe Vissen::Input::Message::PitchBendChange do
  subject { Vissen::Input::Message::PitchBendChange }

  let(:channel)  { rand 1...16 }
  let(:bend)     { rand 0..(2**14) - 0x2000 }
  let(:data) do
    bend_low  = (bend + 0x2000) & 0x7F
    bend_high = (bend + 0x2000) >> 7

    [0xE0 + channel, bend_low, bend_high]
  end
  let(:timestamp) { Time.now.to_f }

  let(:msg) { subject.new data, timestamp }

  describe '.matcher' do
    it 'returns a matcher that matches note data' do
      assert subject.matcher.match? data
    end

    it 'returns a matcher that does not match other data' do
      refute subject.matcher.match?([0xB0, 0, 0])
    end
  end

  describe '#raw' do
    it 'returns the raw pitch bend value' do
      assert_equal bend, msg.raw
    end
  end

  describe '#value' do
    it 'returns the pitch bend as a float in the range -1..1' do
      assert_in_epsilon bend.to_f / 0x2000, msg.value
    end
  end
end
