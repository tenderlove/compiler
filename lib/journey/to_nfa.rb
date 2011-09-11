require 'journey/definition/node'

module Journey
  class ToNFA < Journey::Definition::Node::Visitor
    def initialize
      @index = -1
    end

    def accept node
      super(node).first
    end

    def visit_SYMBOL sym
      left  = Compiler::State.new(@index += 1)
      right = Compiler::State.new(@index += 1, nil, true)
      left.transitions << Compiler::Edge.new(sym.children, right)
      [left, right]
    end

    def visit_SLASH slash
      left     = Compiler::State.new(@index += 1)
      child    = visit slash.children.first
      right    = child.last

      left.transitions << Compiler::Edge.new('/', child.first)
      [left, right]
    end

    def visit_DOT dot
      left     = Compiler::State.new(@index += 1)
      child    = visit dot.children.first
      right    = child.last

      left.transitions << Compiler::Edge.new('DOT', child.first)
      [left, right]
    end

    def visit_GROUP group
      left     = Compiler::State.new(@index += 1)
      child    = combine group.children.map { |c| visit c }
      right    = Compiler::State.new(@index += 1, nil, true)

      child.last.accepting = false

      left.transitions       << Compiler::Edge.new(nil, child.first)
      child.last.transitions << Compiler::Edge.new(nil, right)
      left.transitions       << Compiler::Edge.new(nil, right)
      [left, right]
    end

    def visit_LITERAL literal
      left  = Compiler::State.new(@index += 1)
      right = Compiler::State.new(@index += 1, nil, true)
      left.transitions << Compiler::Edge.new(literal.children, right)
      [left, right]
    end

    def visit_STAR star
      left   = Compiler::State.new(@index += 1)
      ileft  = Compiler::State.new(@index += 1)
      iright = Compiler::State.new(@index += 1)
      right  = Compiler::State.new(@index += 1, nil, true)

      left.transitions   << Compiler::Edge.new(nil, ileft)
      ileft.transitions  << Compiler::Edge.new(star.children, iright)
      iright.transitions << Compiler::Edge.new(nil, right)
      iright.transitions << Compiler::Edge.new(nil, ileft)

      [left, right]
    end

    def visit_PATH path
      children = path.children.map { |c| visit c }
      combine(children)
    end

    # r = s|t
    def visit_OR node
      left   = Compiler::State.new(@index += 1)
      children = node.children.map { |c| visit c }
      right  = Compiler::State.new(@index += 1, nil, true)
      children.each do |cleft, cright|
        cright.accepting = false
        left.transitions << Compiler::Edge.new(nil, cleft)
        cright.transitions << Compiler::Edge.new(nil, right)
      end

      [left, right]
    end

    def combine list
      head     = list.shift

      list.inject(head) { |(_, right), obj|
                          right.accepting = false
                          right.transitions << Compiler::Edge.new(nil, obj.first)
                          obj
      }

      [head.first, (list.last || head).last]
    end
  end
end
