require 'test_helper'

class Vissen::InputTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Vissen::Input::VERSION
  end
end
