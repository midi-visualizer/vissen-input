# frozen_string_literal: true

require 'test_helper'

describe Vissen::Input::Matcher do
  subject { Vissen::Input::Matcher }

  let(:msg_klass) { Vissen::Input::Message::Note }
  let(:msg)       { msg_klass.create }
  let(:matcher)   { msg_klass.matcher }

  describe '#match?' do
    it 'returns true for a matching data array' do
      assert_operator matcher, :match?, [0x90, 0, 0]
    end

    it 'returns true for a matching hash' do
      assert_operator matcher, :match?, data: [0x90, 0, 0]
    end

    it 'returns true for a matching message instance' do
      assert_operator matcher, :match?, msg
    end

    it 'returns false for a different data array' do
      refute_operator matcher, :match?, [0xE0, 0, 0]
    end

    it 'returns false for a matching message instance' do
      msg = Vissen::Input::Message::ProgramChange.create
      refute_operator matcher, :match?, msg
    end
  end
end
