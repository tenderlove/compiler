require 'helper'

module Compiler
  class TestCompiler < Compiler::TestCase
    def test_states
      start = figure_3_34
      assert_includes start.states, start
    end

    def test_nil_closure
      start = figure_3_34
      assert_equal [0, 1, 2, 4, 7], start.nil_closures.map { |x| x.index }.sort
    end
  end
end
