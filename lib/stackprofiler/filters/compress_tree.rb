module Stackprofiler
  module Filter
    class CompressTree
      def filter root, frames
        depths = Hash.new {|h, k| h[k] = [] }
        root.each {|n| depths[n.node_depth].push n }
        depths.delete 0

        depths.keys.sort.reverse.each do |depth|
          nodes = depths[depth]
          nodes.each do |node|
            if node.out_degree == 1
              hash = node.content.dup
              hash[:addrs] = hash[:addrs] + node.first_child.content[:addrs]
              repl = Tree::TreeNode.new(node.name, hash)
              node.first_child.children.each {|n| repl << n }
              node.replace_with repl
            end
          end
        end
        root
      end
    end
  end
end
