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

        sorted_children = root.children.sort_by do |child|
          addr = child.content[:addrs].first.to_i
          cframe = frames[addr]
          cframe[:samples]
        end.reverse

        children = sorted_children.map { |n| filter(n, frames) }
        open = root.content.has_key?(:open) ? root.content[:open] : frame[:total_samples] > 100
        {text: text, state: {opened: open}, children: children, icon: false, data: {addrs: addrs}}
      end
    end

  end
end

