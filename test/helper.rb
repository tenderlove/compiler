require 'minitest/autorun'
require 'compiler'

module Compiler
  class TestCase < MiniTest::Unit::TestCase
    # Figure 3.34
    def figure_3_34
      states = 11.times.map { |i| State.new i }

      states[0].edges << Edge.new(nil, states[1])
      states[0].edges << Edge.new(nil, states[7])

      states[1].edges << Edge.new(nil, states[2])
      states[1].edges << Edge.new(nil, states[4])

      states[2].edges << Edge.new(:a, states[3])

      states[4].edges << Edge.new(:b, states[5])

      states[3].edges << Edge.new(nil, states[6])
      states[5].edges << Edge.new(nil, states[6])

      states[6].edges << Edge.new(nil, states[1])
      states[6].edges << Edge.new(nil, states[7])

      states[7].edges << Edge.new(:a, states[8])
      states[8].edges << Edge.new(:b, states[9])
      states[9].edges << Edge.new(:b, states[10])

      states.first
    end
  end
end
