module Tree
  class TreeNode
    def reverse_depth_first &blk
      depths = Hash.new {|h, k| h[k] = [] }
      root.each {|n| depths[n.node_depth].push n }
      depths.delete 0
      keys = depths.keys.sort.reverse

      keys.each do |depth|
        nodes = depths[depth]
        nodes.each &blk
      end
    end
  end
end
