require 'test_helper'

describe Vissen::Input::MessageFactory do
  subject { Vissen::Input::MessageFactory }

  let(:data)      { [0x90, 0, 0] }
  let(:timestamp) { Time.now.to_f }
  let(:matcher)   { Vissen::Input::Message::Note.matcher }
  let(:factory)   { subject.new }

  before { factory.add_matcher matcher }

  describe '#build' do
    it 'creates a new instance of the matching message class' do
      msg = factory.build data, timestamp

      assert_kind_of Vissen::Input::Message::Note, msg
      assert_equal data,      msg.data
      assert_equal timestamp, msg.timestamp
    end

    it 'returns nil for unmatched data' do
      data = [0, 0, 0]
      msg  = factory.build data, timestamp

      assert_kind_of Vissen::Input::Message::Unknown, msg
      assert_equal data,      msg.data
      assert_equal timestamp, msg.timestamp
    end
  end
end
