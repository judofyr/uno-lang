require_relative 'helper'
require 'uno/parser'

module Uno
  class TestParser < MiniTest::Unit::TestCase
    def test_int
      exp = Parser.parse("1")
      assert_equal [:integer, 1], exp
    end

    def test_string
      exp = Parser.parse('"hello"')
      assert_equal [:string, "hello"], exp
    end

    def test_assign
      exp = Parser.parse("a = 1")
      assert_equal [:assign, "a", [:integer, 1]], exp
    end

    def test_recs
      exp = Parser.parse("{ a: 1, b: 2 }")
      assert_equal [:recmerge,
        [:recset, "a", [:integer, 1]],
        [:recset, "b", [:integer, 2]]], exp
    end

    def test_access
      exp = Parser.parse("rec.a")
      assert_equal [:access, [:var, "rec"], "a"], exp
    end

    def test_method_calls
      exp = Parser.parse("point:x")
      assert_equal [:method, [:var, "point"], "x", []], exp

      exp = Parser.parse("point:translate(1)")
      assert_equal [:method, [:var, "point"], "translate", [[:integer, 1]]], exp

      exp = Parser.parse("point:translate(1, 2)")
      assert_equal [:method, [:var, "point"], "translate", [[:integer, 1], [:integer, 2]]], exp
    end

    def test_calls
      exp = Parser.parse('puts("Hello")')
      assert_equal [:call, [:var, "puts"], [[:string, "Hello"]]], exp
    end
  end
end

