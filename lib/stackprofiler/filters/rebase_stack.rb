module Stackprofiler
  module Filter
    class RebaseStack
      attr_accessor :top_names

      def initialize(options={})
        self.top_names = options[:name].presence || RebaseStack.default
      end

      def filter root, frames
        root.find do |node|
          addr = node.content[:addrs].first.to_i
          top_names.include? frames[addr][:name]
          # frames[addr][:name] == top_names
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
