module Stackprofiler
  module Filter
    class StackprofilerElision
      def filter root, frames
        root.find do |node|
          addr = node.content[:addrs].first.to_i
          frames[addr][:name] == 'Stackprofiler::DataCollector#call'
        end
      end
    end
  end
end
