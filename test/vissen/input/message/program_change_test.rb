# frozen_string_literal: true

require 'test_helper'

describe Vissen::Input::Message::ProgramChange do
  subject { Vissen::Input::Message::ProgramChange }

  let(:channel)   { rand 1...16 }
  let(:number)    { rand 120..127 }
  let(:data) do
    [0xC0 + channel, number]
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

  describe '#number' do
    it 'returns the number' do
      assert_equal number, msg.number
    end
  end
end
