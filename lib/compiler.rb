# encoding: utf-8

require 'compiler/nfa'
require 'journey/definition/parser'
require 'journey/to_nfa'
require 'journey/ast_graph'

module Compiler
  VERSION = '1.0.0'

  module Visitors
    class Dot
      def initialize
        @marked = {}
      end

      def accept node
        nodes = []
        edges = []

        stack = [node]
        while !stack.empty?
          n = stack.pop
          next if marked? n
          mark n

          nodes << "#{n.index} [label=\"#{n.label || n.index}\"];"
          n.transitions.each do |t|
            edges << "#{n.index} -> #{t.to.index} [label=\"#{t.symbol || 'ϵ'}\"];"
            stack << t.to
          end
        end

        <<-eodot
digraph finite_state_machine {
  rankdir=LR;
  size="8,5"
  node [shape = doublecircle];
  #{node.states.find_all { |s| s.accepting? }.map { |s| s.index }.join ' '};
  node [shape = circle];
  #{nodes.join("\n") + edges.join("\n")}
}
        eodot
      end

      private
      def mark node
        @marked[node] = true
      end

      def marked? node
        @marked[node]
      end
    end

    class Each
      def initialize block
        @block = block
        @seen  = {}
      end

      def accept node
        return if @seen.key? node

        @seen[node] = true

        case node
        when State then state node
        when Edge  then edge node
        end
      end

      private
      def state s
        @block.call s
        s.transitions.each { |e| accept e }
      end

      def edge e
        @block.call e
        accept e.to
      end
    end
  end

  class State
    include Enumerable

    attr_accessor :index, :label, :transitions
    attr_accessor :accepting
    alias :accepting? :accepting

    def initialize index, label = nil, accepting = false
      @index       = index
      @label       = label
      @accepting   = accepting
      @transitions = []
    end

    def each &block
      Visitors::Each.new(block).accept self
    end

    def to_dot
      Visitors::Dot.new.accept self
    end

    def states
      grep(State)
    end

    def nil_closures
      nil_closures = transitions.find_all { |e|
        e.symbol.nil?
      }.map { |e| e.to.nil_closures }.flatten

      [self] + nil_closures
    end
  end

  class Edge
    attr_reader :symbol, :to

    def initialize symbol, to
      @symbol = symbol
      @to     = to
    end
  end
end
