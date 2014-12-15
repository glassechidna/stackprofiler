module Stackprofiler
  module Filter
    class BuildTree
      def initialize(options={})
        @options = options
      end

      def filter run, frames
        stacks = run.stacks

        root_addr = stacks[0][0].to_s
        root = Tree::TreeNode.new root_addr, {addrs: [root_addr]}

        stacks.each do |stack|
          prev = root
          iterate stack do |addr|
            addr = addr.to_s
            node = prev[addr]
            if node.nil?
              hash = {count: 0, addrs: [addr]}
              node = Tree::TreeNode.new(addr, hash)
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
