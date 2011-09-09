require 'minitest/autorun'
require 'compiler'

module Compiler
  class TestCase < MiniTest::Unit::TestCase
    # Figure 3.34
    def figure_3_34
      states = 11.times.map { |i| State.new i }
      states[10].accepting = true

      states[0].transitions << Edge.new(nil, states[1])
      states[0].transitions << Edge.new(nil, states[7])

      states[1].transitions << Edge.new(nil, states[2])
      states[1].transitions << Edge.new(nil, states[4])

      states[2].transitions << Edge.new(:a, states[3])

      states[4].transitions << Edge.new(:b, states[5])

      states[3].transitions << Edge.new(nil, states[6])
      states[5].transitions << Edge.new(nil, states[6])

      states[6].transitions << Edge.new(nil, states[1])
      states[6].transitions << Edge.new(nil, states[7])

      states[7].transitions << Edge.new(:a, states[8])
      states[8].transitions << Edge.new(:b, states[9])
      states[9].transitions << Edge.new(:b, states[10])

      states.first
    end
  end
end
