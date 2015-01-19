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

    def code_cache
      @code_cache ||= RunCodeCache.new @profile
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

    def gem_breakdown
      bottom_frames = stacks.map &:last
      paths = bottom_frames.map {|addr| profile[:frames][addr][:file] }

      gems = paths.map do |p|
        case p
          when %r{gems/(\D\w+)}
            $1
          when %r{#{RbConfig::CONFIG['rubylibdir']}}
            'stdlib'
          else
            '(app)'
        end
      end

      gems.group_by {|g| g }.map {|k, v| [k, v.count] }.sort_by(&:last).reverse.to_h
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
