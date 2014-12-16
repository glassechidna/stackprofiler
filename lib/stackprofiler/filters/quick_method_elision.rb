module Stackprofiler
  module Filter
    class QuickMethodElision
      include RemoveFramesHelper

      def initialize(options={})

      end

      def filter root, frames
        remove_frames root, frames do |node, frame|
          frame[:total_samples] < 10
        end
      end
    end
  end
end
