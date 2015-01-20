module Stackprofiler
  module Filter
    class GemRemoval
      include RemoveFramesHelper

      def initialize(options={})
      end

      def filter root, run
        remove_frames root, run do |node, frame|
          Gem.path.any? {|p| frame[:file].include?(p) }
        end
      end
    end
  end
end
