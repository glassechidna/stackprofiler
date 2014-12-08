module Stackprofiler
  module Filter
    class QuickMethodElision
      def filter root, frames
        # depths = Hash.new {|h, k| h[k] = [] }
        # root.each {|n| depths[n.node_depth].push n }
        # depths.delete 0
        # keys = depths.keys.sort.reverse
        #
        # keys.each do |depth|
        #   nodes = depths[depth]
        #   nodes.each do |node|
        #     frame = frames[node.name.to_i]
        #
        #     if frame[:total_samples] < 10
        #       parent = node.parent
        #       node.remove_from_parent!
        #
        #       node.children.each do |n|
        #         n.remove_from_parent!
        #         parent << n if parent[n.name].nil? # todo: have a think about if/why this "if" is necessary
        #       end
        #     end
        #   end
        # end
        #
        # root

        root.reverse_depth_first do |node|
          frame = frames[node.name.to_i]

          if frame[:total_samples] < 10
            parent = node.parent
            node.remove_from_parent!

            node.children.each do |n|
              n.remove_from_parent!
              parent << n if parent[n.name].nil? # todo: have a think about if/why this "if" is necessary
            end
          end
        end
        root
      end
    end
  end
end
