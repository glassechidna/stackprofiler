module Stackprofiler
  module Filter
    class FrameRegexRemoval
      include RemoveFramesHelper

      def initialize(options={})
        @options = options
      end

      def regexes
        ary = @options[:regexes] || []
        @regexes ||= ary.reject(&:blank?).map {|r| /#{r}/ }.compact
      end

      def filter root, run
        remove_frames root, run do |node, frame|
          regexes.any? {|r| frame[:name] =~ r }
        end
      end
    end
  end
end
