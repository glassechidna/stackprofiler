module Stackprofiler
  class Run
    attr_accessor :url
    attr_accessor :profile
    attr_accessor :timestamp

    def initialize(url, profile, timestamp)
      @url = url
      @profile = profile
      @timestamp = timestamp
    end

    def stacks
      @stacks ||= begin
        off = 0
        stacks = []
        raw = @profile[:raw]
        while off < raw.length
          len = raw[off]
          these_frames = raw[off + 1..off + len]
          off += len + 2

          stacks.push these_frames
        end
        stacks
      end
    end

    def duration
      profile[:samples] * profile[:interval] / 1e6
    end
  end

  class RunDataSource
    class << self
      RUNS = []

      def runs
        RUNS
      end
    end
  end
end
