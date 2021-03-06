module Stackprofiler
  module Filter
    class JsTree
      def initialize(options={})

      end

      def filter root, run
        addrs = root.content[:addrs]
        name = addrs.first
        frames = run.profile[:frames]
        frame = frames[name]

        escaped = addrs.map do |addr|
          this_frame = frames[addr]
          this_name = CGI::escapeHTML(this_frame[:name])
          "#{this_name} (<b>#{this_frame[:samples]}</b>)"
        end
        text = escaped.join("<br> ↳ ").presence || root.name

        sorted_children = root.children.sort_by do |child|
          addr = child.content[:addrs].first
          cframe = frames[addr]
          cframe[:samples]
        end.reverse

        children = sorted_children.map { |n| filter(n, run) }
        open = root.content.has_key?(:open) ? root.content[:open] : frame[:total_samples] > 100
        {text: text, state: {opened: open}, children: children, icon: false, data: {addrs: addrs}}
      end
    end

  end
end

