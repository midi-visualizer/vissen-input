# frozen_string_literal: true

require 'test_helper'

describe Vissen::Input::Message::Aftertouch do
  subject { Vissen::Input::Message::Aftertouch }

  let(:channel)   { rand 1...16 }
  let(:note)      { rand 0..127 }
  let(:preassure) { rand 0..127 }
  let(:data) do
    [0xA0 + channel, note, preassure]
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

  describe '#valid?' do
    it 'returns true when the data is valid' do
      assert msg.valid?
    end

    it 'returns false when the data is not valid' do
      msg = subject.new [0xB0, 0, 0], timestamp
      refute msg.valid?
    end
  end

  describe '#note' do
    it 'returns the note' do
      assert_equal note, msg.note
    end
  end

  describe '#preassure' do
    it 'returns the preassure' do
      assert_equal preassure, msg.preassure
    end
  end
end
