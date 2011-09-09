require 'helper'

module Compiler
  class TestNFA < Compiler::TestCase
    attr_reader :nfa

    def setup
      @nfa = NFA.new figure_3_34
    end

    def test_eclosure_0
      assert_equal [0, 1, 2, 4, 7], nfa.eclosure(0)
    end

    def test_move_A_a
      _A = nfa.eclosure(0)
      assert_equal [3,8], nfa.move(_A, :a)
    end

    def test_move_A_b
      _A = nfa.eclosure(0)
      assert_equal [5], nfa.move(_A, :b)
    end

    def test_eclosure_3_8
      assert_equal [1,2,3,4,6,7,8], nfa.eclosure([3, 8])
    end

    def test_eclosure_5
      assert_equal [1,2,4,5,6,7], nfa.eclosure([5])
    end

    def test_dfa_transition_states
      dtran = nfa.dfa_transitions

      assert_equal 'A', dtran[[0,1,2,4,7]].label
      assert_equal 'B', dtran[[1,2,3,4,6,7,8]].label
      assert_equal 'C', dtran[[1,2,4,5,6,7]].label
      assert_equal 'D', dtran[[1,2,4,5,6,7,9]].label
      assert_equal 'E', dtran[[1,2,4,5,6,7,10]].label
    end

    def test_alphabet
      nfa = NFA.new figure_3_34

      assert_equal [:a, :b], nfa.alphabet
    end
  end
end
