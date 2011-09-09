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

    def test_dfa_transition_edges
      dtran = nfa.dfa_transitions
      _A = dtran[nfa.eclosure(0)]

      # A points to B and C
      assert_equal 2, _A.transitions.length
      assert_equal [:a, :b], _A.transitions.map { |t| t.symbol }
      assert_equal 'B', _A.transitions.find { |t| t.symbol == :a }.to.label
      assert_equal 'C', _A.transitions.find { |t| t.symbol == :b }.to.label

      # B points to B and D
      _B = _A.transitions.find { |t| t.symbol == :a }.to
      assert_equal 2, _B.transitions.length
      assert_equal [:a, :b], _B.transitions.map { |t| t.symbol }
      assert_equal 'B', _B.transitions.find { |t| t.symbol == :a }.to.label
      assert_equal 'D', _B.transitions.find { |t| t.symbol == :b }.to.label

      # C points to C and B
      _C = _A.transitions.find { |t| t.symbol == :b }.to
      assert_equal 2, _C.transitions.length
      assert_equal [:a, :b], _C.transitions.map { |t| t.symbol }
      assert_equal 'B', _C.transitions.find { |t| t.symbol == :a }.to.label
      assert_equal 'C', _C.transitions.find { |t| t.symbol == :b }.to.label

      # D points to B and E
      _D = _B.transitions.find { |t| t.symbol == :b }.to
      assert_equal 2, _D.transitions.length
      assert_equal [:a, :b], _D.transitions.map { |t| t.symbol }
      assert_equal 'B', _D.transitions.find { |t| t.symbol == :a }.to.label
      assert_equal 'E', _D.transitions.find { |t| t.symbol == :b }.to.label

      # E points to C and B
      _E = _D.transitions.find { |t| t.symbol == :b }.to
      assert_equal 2, _E.transitions.length
      assert_equal [:a, :b], _E.transitions.map { |t| t.symbol }
      assert_equal 'B', _E.transitions.find { |t| t.symbol == :a }.to.label
      assert_equal 'C', _E.transitions.find { |t| t.symbol == :b }.to.label
    end

    def test_alphabet
      nfa = NFA.new figure_3_34

      assert_equal [:a, :b], nfa.alphabet
    end
  end
end
