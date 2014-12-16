module Stackprofiler
  module Filter
    class RemoveFrames
      def initialize(options={})
        @options = options
      end

      def regexes
        ary = @options[:regexes] || []
        @regexes ||= ary.reject(&:blank?).map {|r| /#{r}/ }.compact
      end

      def filter root, frames
        # todo: have a think about why straight enumeration isn't good enough

        root.reverse_depth_first do |node|
          frame = frames[node.name.to_i]

          if regexes.any? {|r| frame[:name] =~ r }
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
