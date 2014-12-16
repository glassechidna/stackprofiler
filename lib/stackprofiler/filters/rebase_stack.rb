module Stackprofiler
  module Filter
    class RebaseStack
      attr_accessor :top_name

      def initialize(options={})
        self.top_name = options[:name].presence || RebaseStack.default
      end

      def filter root, frames
        root.find do |node|
          addr = node.content[:addrs].first.to_i
          frames[addr][:name] == top_name
        end || root
      end

      class << self
        def default
          'Stackprofiler::DataCollector#call'
        end
      end
    end
  end
end
