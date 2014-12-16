module Stackprofiler
  module Filter
    class GemRemoval
      include RemoveFramesHelper

      def initialize(options={})
      end

      def filter root, frames
        remove_frames root, frames do |node, frame|
          Gem.path.any? {|p| frame[:file].include?(p) }
        end
      end
    end
  end
end
