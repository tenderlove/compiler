module Compiler
  class DFA
    class TransitionTable
      def initialize
        @cache = Hash.new { |h,nfa|
          h[nfa] = State.new(h.length, (65 + h.length).chr)
        }
      end

      def nfa_states
        @cache.keys
      end

      def [] from
        @cache[from]
      end

      def []= from, symbol, to
        @cache[from].transitions << Edge.new(symbol, @cache[to])
      end
    end
  end

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
        state.nil_closures.map { |s| s.index }.sort
      end
    end

    def dfa_transitions
      dtran = DFA::TransitionTable.new
      marked  = {}
      stack = [eclosure(0)]
      while !stack.empty?
        state = stack.pop
        next if marked[state]
        marked[state] = true # mark

        alphabet.each do |sym|
          next_state = eclosure(move(state, sym))
          stack << next_state
          dtran[state, sym] = next_state
        end
      end

      # find accepting states in the nfa
      accepting_states = @tree.states.find_all { |s|
        s.accepting?
      }.map { |s| s.index }

      # mark accepting states in the dfa
      dtran.nfa_states.each do |states|
        if (accepting_states - states).empty?
          dtran[states].accepting = true
        end
      end

      dtran
    end

    def move idxs, symbol
      idxs.map { |i|
        states[i].transitions.find_all { |t|
          t.symbol == symbol
        }.map { |t| t.to.index }
      }.flatten.compact.sort
    end

    private
    def states
      @states ||= @tree.states.sort_by { |s| s.index }
    end
  end
end
