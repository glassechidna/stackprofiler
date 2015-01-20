module Stackprofiler
  module Filter
    class QuickMethodRemoval
      include RemoveFramesHelper
      attr_accessor :limit

      def initialize(options={})
        self.limit = options[:limit].try(:to_i) || 0
      end

      def filter root, run
        remove_frames root, run do |node, frame|
          frame[:total_samples] < limit
        end
      end
    end
  end
end
