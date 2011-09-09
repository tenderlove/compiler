module Compiler
  class NFA
    def initialize tree
      @tree   = tree
      @states = nil
    end

    def alphabet
      @tree.grep(Edge).map { |e| e.symbol }.compact.uniq
    end

    def eclosure idx
      if Array === idx
        idx.map { |i| eclosure(i) }.flatten.sort
      else
        state = states[idx]
        state.nil_closures.map { |s| s.name }.sort
      end
    end

    def move idxs, symbol
      idxs.map { |i|
        states[i].transitions.find_all { |t|
          t.symbol == symbol
        }.map { |t| t.to.name }
      }.flatten.compact.sort
    end

    private
    def states
      @states ||= @tree.states.sort_by { |s| s.name }
    end
  end
end
