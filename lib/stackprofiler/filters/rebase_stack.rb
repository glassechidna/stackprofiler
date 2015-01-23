module Stackprofiler
  module Filter
    class RebaseStack
      attr_accessor :top_names

      def initialize(options={})
        self.top_names = options[:name].presence || RebaseStack.default
      end

      def filter root, run
        root.find do |node|
          next if node == root
          addr = node.content[:addrs].first.to_i
          frame = run.profile[:frames][addr]
          top_names.include?(frame[:name]) || run.profile[:suggested_rebase] == addr
        end || root
      end

      class << self
        def default
          ['Stackprofiler::DataCollector#call', 'block in Stackprofiler#profile']
        end
      end
    end
  end
end
