module Stackprofiler
  module Filter
    class RebaseStack
      attr_accessor :manual

      def initialize(options={})
        self.manual = options[:name].presence
      end

      def filter root, run
        suggested = run.profile[:suggested_rebase]

        root.find do |node|
          next if node == root
          addr = node.content[:addrs].first.to_i
          frame = run.profile[:frames][addr]

          if manual
            frame[:name].include? manual
          elsif suggested.is_a? String
            suggested == frame[:name]
          else
            suggested == addr
          end
        end || root
      end
    end
  end
end
