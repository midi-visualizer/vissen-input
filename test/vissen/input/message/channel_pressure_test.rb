# frozen_string_literal: true

require 'test_helper'

describe Vissen::Input::Message::ChannelPressure do
  subject { Vissen::Input::Message::ChannelPressure }

  let(:channel)   { rand 1...16 }
  let(:pressure)  { rand 120..127 }
  let(:data) do
    [0xD0 + channel, pressure]
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

  describe '#pressure' do
    it 'returns the pressure' do
      assert_equal pressure, msg.pressure
    end
  end
end
