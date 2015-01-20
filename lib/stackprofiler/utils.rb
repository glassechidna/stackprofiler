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

module Stackprofiler
  def profile
    # todo: pass through options perhaps?
    profile = StackProf.run(mode: :wall, raw: true) { yield }
    # todo: remove terrible hard-coded url
    url = URI::parse 'http://localhost:9292/__stackprofiler/receive'
    headers = {'Content-Type' => 'application/json'}
    req = Net::HTTP::Post.new(url.to_s, headers)
    req.body = Oj.dump profile
    response = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
  end
  module_function :profile

  module Filter
    module RemoveFramesHelper
      def remove_frames root, run
        root.reverse_depth_first do |node|
          frame = run.profile[:frames][node.name.to_i]

          if yield node, frame
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
