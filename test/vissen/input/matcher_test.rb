require 'test_helper'

describe Vissen::Input::Matcher do
  subject { Vissen::Input::Matcher }
  
  let(:msg_klass) { Vissen::Input::Message::Note }
  let(:msg)       { msg_klass.create }
  let(:matcher)   { msg_klass.matcher }
  
  describe '#match?' do
    it 'returns true for a matching data array' do
      assert matcher.match?([0x90, 0, 0])
    end
    
    it 'returns true for a matching message instance' do
      assert matcher.match?(msg)
    end
    
    it 'returns false for a different data array' do
      refute matcher.match?([0xE0, 0, 0])
    end
    
    it 'returns true for a matching message instance' do
      msg = Vissen::Input::Message::ProgramChange.create
      refute matcher.match?(msg)
    end
  end
end
