module Stackprofiler
  module Filter
    class GemRemoval
      include RemoveFramesHelper

      def initialize(options={})
      end

      def filter root, run
        remove_frames root, run do |node, frame|
          # todo: gem determination depends on gems being
          # run from the same interpreter/rubygems path
          # as stackprofiler. is that a good idea?
          Gem.path.any? {|p| frame[:file].include?(p) }
        end
      end
    end
  end
end
