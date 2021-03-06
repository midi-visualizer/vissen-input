# frozen_string_literal: true

require 'test_helper'

describe Vissen::Input do
  it 'has a version number' do
    refute_nil ::Vissen::Input::VERSION
  end

  it 'can distribute messages' do
    broker = Vissen::Input::Broker.new
    control_change_received = false
    note_received = false
    pitch_bend_change_received = false

    # It should match an entire message type
    broker.subscribe Vissen::Input::Message::PitchBendChange do |msg|
      pitch_bend_change_received = true
      assert_in_epsilon(-0.3386, msg.value)
    end

    # It should match only channel 15 of the message type
    broker.subscribe Vissen::Input::Message::Note[15] do |msg|
      refute note_received
      note_received = true

      assert_equal 15, msg.channel
      assert_equal 1, msg.note
    end

    # It should match only channel 15, control change
    # number 5
    broker.subscribe Vissen::Input::Message::ControlChange[3, 5] do |msg|
      refute control_change_received
      control_change_received = true

      assert_equal 3, msg.channel
      assert_equal 5, msg.number
      assert_equal 1, msg.value
    end

    # Step 1
    # Simulate messages arriving from a raw data stream
    messages = [
      # Note on
      { data: [0x90 + 14, 0, 0], timestamp: 4.2 }, # This should not match
      { data: [0x90 + 15, 1, 0], timestamp: 4.3 }, # This should
      # Control Change
      { data: [0xB0 + 3, 5, 1], timestamp: 4.4 },  # This too
      { data: [0xB0 + 3, 4, 0], timestamp: 4.5 },  # But not this
      # Pitch Bend Change
      { data: [0xE0, 42, 42], timestamp: 4.6 }
    ]

    # Step 2
    # Publish the messages
    messages.each { |msg| broker.publish msg }

    # Step 3
    # Run the broker
    5.times { broker.run_once }

    assert control_change_received
    assert note_received
    assert pitch_bend_change_received
  end
end
