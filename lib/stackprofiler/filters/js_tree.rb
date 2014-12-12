module Stackprofiler
  module Filter
    class JsTree
      def initialize(options={})

      end

      def filter root, frames
        addrs = root.content[:addrs]
        name = addrs.first.to_i
        frame = frames[name]

        escaped = addrs.map do |addr|
          this_frame = frames[addr.to_i]
          this_name = CGI::escapeHTML(this_frame[:name])
          "#{this_name} (<b>#{this_frame[:samples]}</b>)"
        end
        text = escaped.join("<br> ↳ ")

        children = root.children.map { |n| filter(n, frames) }
        open = frame[:total_samples] > 100
        {text: text, children: children, state: {opened: open}, icon: false, data: {addrs: addrs}}
      end
    end

  end
end

