module Stackprofiler
  module Filter
    class QuickMethodElision
      def filter root, frames
        root.each do |node|
          next if node == root

          addr = node.name.to_i
          frame = frames[addr]
          if frame[:samples] < 10
            parent = node.parent
            node.remove_from_parent!

            node.children.each do |n|
              n.remove_from_parent!
              parent << n
            end
          end
        end
        root
      end
    end
  end

  class WebUI < Sinatra::Base
    helpers Sinatra::ContentFor
    set :views, proc { File.join(root, 'web_ui', 'views') }
    set :public_folder, proc { File.join(root, 'web_ui', 'public') }

    get '/' do
      @runs = RunDataSource.runs
      @run_id = params[:run_id].try(:to_i) || (@runs.count - 1)
      erb :index
    end

    get '/stats' do
      content_type 'application/json'
      RunDataSource.runs.map do |run|
        objs = ObjectSpace.reachable_objects_from run.profile
        objs.reduce(0) {|size, obj| size + ObjectSpace::memsize_of(obj) }
      end.to_json
    end

    get '/frames' do
      content_type 'application/json'
      run_id = params[:run_id].to_i
      run = RunDataSource.runs[run_id]
      run.profile[:frames].to_json
    end

    get '/code/:addr' do
      addr = params[:addr].to_i

      run_id = params[:run_id].to_i
      run = RunDataSource.runs[run_id]

      data = run.profile
      frames = data[:frames]

      frame = frames[addr]
      halt 404 if frame.nil?

      file, first_line = frame.values_at :file, :line
      first_line ||= 1

      last_line = frame[:lines].keys.max || first_line + 5
      line_range = first_line..last_line

      @source = File.readlines(file).select.with_index {|line, idx| line_range.include? (idx + 1) }.join
      @output = CodeRay.scan(@source, :ruby).div(wrap: nil).lines.map.with_index do |code, idx|
        line_index = idx + first_line
        samples = frame[:lines][line_index] || []
        {code: code, samples: samples.first}
      end

      erb :code, layout: nil
    end

    get '/json' do
      content_type 'application/json'

      run_id = params[:run_id].to_i
      run = RunDataSource.runs[run_id]
      frames = run.profile[:frames]
      stacks = run.stacks

      root_addr = stacks[0][0].to_s
      root = Tree::TreeNode.new root_addr, {text: 'root', addrs: [root_addr]}

      stacks.each do |stack|
        prev = root
        stack.each do |addr|
          addr = addr.to_s
          node = prev[addr]
          if node.nil?
            hash = {count: 0, text: frames[addr.to_i][:name], addrs: [addr]}
            node = Tree::TreeNode.new(addr, hash)
            prev << node
          end
          node.content[:count] +=1
          prev = node
        end
      end

      filters = [Filter::StackprofilerElision.new, Filter::CompressTree.new, Filter::JsTree.new]
      filtered = filters.reduce(root) {|memo, filter| filter.filter(memo, frames) }

      Oj.dump(filtered, mode: :compat)
    end
  end
end
