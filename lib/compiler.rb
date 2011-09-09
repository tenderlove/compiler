require 'compiler/nfa'

module Compiler
  VERSION = '1.0.0'

  module Visitors
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
        s.edges.each { |e| accept e }
      end

      def edge e
        @block.call e
        accept e.to
      end
    end
  end

  class State
    include Enumerable

    attr_reader :name, :edges
    alias :transitions :edges

    def initialize name
      @name  = name
      @edges = []
    end

    def each &block
      Visitors::Each.new(block).accept self
    end

    def states
      grep(State)
    end

    def nil_closures
      nil_closures = edges.find_all { |e|
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
