module Stackprofiler
  module Filter
    class BuildTree
      def initialize(options={})
        @options = options
      end

      def filter run, run2
        stacks = run.stacks

        root = StandardWarning.disable { Tree::TreeNode.new '(Root)', {addrs: [], open: true} }
        all = {root_addr: root}

        stacks.each do |stack|
          prev = root
          iterate stack[1..-1] do |addr|
            node = all[addr]
            if node.nil?
              hash = {count: 0, addrs: [addr]}
              node = StandardWarning.disable { Tree::TreeNode.new(addr, hash) }
              all[addr] = node
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
