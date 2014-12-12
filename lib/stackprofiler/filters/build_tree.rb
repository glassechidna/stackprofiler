module Stackprofiler
  module Filter
    class BuildTree
      def initialize(options={})

      end

      def filter run, frames
        stacks = run.stacks

        root_addr = stacks[0][0].to_s
        root = Tree::TreeNode.new root_addr, {addrs: [root_addr]}

        stacks.each do |stack|
          prev = root
          stack.each do |addr|
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

        root
      end
    end
  end
end
