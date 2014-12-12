module Stackprofiler
  class WebUI < Sinatra::Base
    helpers Sinatra::ContentFor
    set :views, proc { File.join(root, 'web_ui', 'views') }
    set :public_folder, proc { File.join(root, 'web_ui', 'public') }

    def initialize(options={})
      if options[:file]
        data = File.read options[:file]
        run = Oj.load data
        RunDataSource.runs << run
      end

      super
    end

    configure :development do
      require 'better_errors'
      use BetterErrors::Middleware
      BetterErrors.application_root = __dir__
    end

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
      run.profile[:frames].sort_by {|addr, frame| frame[:samples] }.to_json
    end

    get '/code/:addr' do
      addr = params[:addr].to_i

      run_id = params[:run_id].to_i
      run = RunDataSource.runs[run_id]

      data = run.profile
      frames = data[:frames]

      frame = frames[addr]
      halt 404 if frame.nil?

      @file, @first_line = frame.values_at :file, :line
      @first_line ||= 1

      last_line = frame[:lines].keys.max || @first_line + 5
      line_range = @first_line..last_line

      @source = File.readlines(@file).select.with_index {|line, idx| line_range.include? (idx + 1) }.join
      @output = CodeRay.scan(@source, :ruby).div(wrap: nil).lines.map.with_index do |code, idx|
        line_index = idx + @first_line
        samples = frame[:lines][line_index] || []
        {code: code, samples: samples.first}
      end

      erb :code, layout: nil
    end

    post '/json' do
      json_params = Oj.strict_load(request.body.read, nil)
      params.merge!(json_params)

      run_id = params[:run_id].to_i
      run = RunDataSource.runs[run_id]
      frames = run.profile[:frames]

      filter_map = {
        stackprofiler_elision: Filter::StackprofilerElision,
        remove_gems: Filter::RemoveGems,
        quick_method_elision: Filter::QuickMethodElision,
        compress_tree: Filter::CompressTree,
      }

      optional = params[:filters].map do |key, opts|
        klass = filter_map[key.to_sym]
        klass.new(opts) if klass.present?
      end.compact

      filters = [Filter::BuildTree.new, *optional, Filter::JsTree.new]
      filtered = filters.reduce(run) {|memo, filter| filter.filter(memo, frames) }

      content_type 'application/json'
      Oj.dump(filtered, mode: :compat)
    end
  end
end
