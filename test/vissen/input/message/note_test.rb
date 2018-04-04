require 'test_helper'

describe Vissen::Input::Message::Note do
  subject { Vissen::Input::Message::Note }

  let(:channel)   { rand 1...16 }
  let(:note)      { rand 0..127 }
  let(:velocity)  { rand 0..127 }
  let(:data_on)   { [0x90 + channel, note, velocity] }
  let(:data_off)  { [0x80 + channel, note, velocity] }
  let(:timestamp) { Time.now.to_f }

  let(:msg)       { subject.new data_on,  timestamp }
  let(:msg_off)   { subject.new data_off, timestamp }
  
  describe '.matcher' do
    it 'returns a matcher that matches note data' do
      matcher = subject.matcher
      
      assert matcher.match? data_on
      assert matcher.match? data_off
    end
    
    it 'returns a matcher that does not match other data' do
      refute subject.matcher.match?([0xB0, 0, 0])
    end
  end
  
  describe '.create' do
    it 'creates a valid note message' do
      msg = subject.create(note, velocity, on: true, channel: channel,
                           timestamp: timestamp)
      
      assert_equal channel,  msg.channel
      assert_equal note,     msg.note
      assert_equal velocity, msg.velocity
      assert_equal data_on,  msg.data
    end
  end

  describe '#note' do
    it 'returns the note' do
      assert_equal note, msg.note
    end
  end

  describe '#velocity' do
    it 'returns the velocity' do
      assert_equal velocity, msg.velocity
    end
  end

  describe '#on?' do
    it 'returns true for note on messages' do
      assert msg.on?
    end

    it 'returns false for note off messages' do
      refute msg_off.on?
    end
  end

  describe '#off?' do
    it 'returns true for note off messages' do
      assert msg_off.off?
    end

    it 'returns false for note on messages' do
      refute msg.off?
    end
  end
end
