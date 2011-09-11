require 'journey/definition/node'

module Journey
  module Definition
    class Node
      def to_dot
        rg = RouteGraph.new
        rg.accept self
        rg.graph
      end
    end
  end
class RouteGraph < Journey::Definition::Node::Visitor
  def initialize
    @nodes = []
    @edges = []
  end

  def graph
    <<-eodot
digraph finite_state_machine {
  rankdir=LR;
  size="8,5"
  node [shape = box];
  #{@nodes.join "\n"}
  #{@edges.join("\n")}
}
    eodot
  end

  def nary node
    @nodes << "#{node.object_id} [label=\"#{node.type}\"];"
    node.children.each do |c|
      @edges << "#{node.object_id} -> #{c.object_id};"
    end
    super
  end

  alias :visit_PATH :nary
  alias :visit_DOT :nary
  alias :visit_SLASH :nary
  alias :visit_GROUP :nary

  def terminal node
    @nodes << "#{node.object_id} [label=\"#{node.type}: #{node.children}\"];"
    super
  end
  alias :visit_STAR :terminal
  alias :visit_LITERAL :terminal
  alias :visit_SYMBOL :terminal
end
end
