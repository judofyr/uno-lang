require_relative 'helper'
require 'uno/parser'

module Uno
  class TestParser < MiniTest::Unit::TestCase
    def test_int
      exp = Parser.parse("1")
      assert_equal [:integer, 1], exp
    end
  end
end

