module Stackprofiler
  module Filter
    class BuildTree
      def initialize(options={})
        @options = options
      end

      def filter run, run2
        stacks = run.stacks

        root = StandardWarning.disable { Tree::TreeNode.new '(Root)', {addrs: [], open: true} }

        stacks.each do |stack|
          prev = root
          iterate stack do |addr|
            # nobody likes hacks, but this halved the page rendering time
            node = prev.instance_variable_get(:@children_hash)[addr]
            if node.nil?
              hash = {count: 0, addrs: [addr]}
              node = StandardWarning.disable { Tree::TreeNode.new(addr, hash) }
              prev << node
            end
            node.content[:count] +=1
            prev = node
          end
        end

        if inverted?
          root.children.each {|n| n.content[:open] = false }
        end

        root
      end

      def inverted?
        @options[:invert]
      end

      def iterate stack, &blk
        if inverted?
          stack.reverse_each &blk
        else
          stack.each &blk
        end
      end
    end
  end
end
