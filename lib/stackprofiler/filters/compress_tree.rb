module Stackprofiler
  module Filter
    class CompressTree
      def initialize(options={})

      end

      def filter root, frames
        root.reverse_depth_first do |node|
          if node.out_degree == 1
            hash = node.content
            hash[:addrs] += node.first_child.content[:addrs]
            repl = Tree::TreeNode.new(node.name, hash)
            node.first_child.children.each {|n| repl << n }
            node.replace_with repl
          end
        end
        root
      end
    end
  end
end
