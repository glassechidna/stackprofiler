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

      @source = MethodSource::source_helper([@file, @first_line]).strip_heredoc
      @output = CodeRay.scan(@source, :ruby).div(wrap: nil).lines.map.with_index do |code, idx|
        line_index = idx + @first_line
        samples = frame[:lines][line_index] || []
        {code: code, samples: samples.join('/') }
      end

      erb :code, layout: nil, trim: '-'
    end

    get '/frame_names' do
      name = params[:term]
      run_id = params[:run_id].to_i

      run = RunDataSource.runs[run_id]
      frames = run.profile[:frames]

      matching = frames.select {|addr, f| f[:name].include? name }
      results = matching.map {|addr, f| f[:name] }

      content_type 'application/json'
      Oj.dump(results, mode: :compat)
    end

    post '/receive' do
      data = request.body.read
      json = Oj.load(data)
      run = Run.new 'unknown', json, Time.now
      RunDataSource.runs << run

      # if they sent us a profile, they probably changed something and want that reflected
      # todo: remove hack
      MethodSource::instance_variable_get(:@lines_for_file).try(:clear)

      content_type 'application/json'
      {run_id: RunDataSource.runs.count - 1 }.to_json
    end

    get '/gem_breakdown' do
      run_id = params[:run_id].to_i
      run = RunDataSource.runs[run_id]

      breakdown = run.gem_breakdown
      breakdown['(gc)'] = run.profile[:gc_samples]

      content_type 'application/json'
      breakdown.to_json
    end

    post '/json' do
      json_params = Oj.strict_load(request.body.read, nil)
      params.merge!(json_params)

      run_id = params[:run_id].to_i
      run = RunDataSource.runs[run_id]
      frames = run.profile[:frames]

      filter_map = [
        {name: :build_tree, klass: Filter::BuildTree, mandatory: true},
        {name: :rebase_stack, klass: Filter::RebaseStack, mandatory: false},
        {name: :filtered_frames, klass: Filter::FrameRegexRemoval, mandatory: false},
        {name: :remove_gems, klass: Filter::GemRemoval, mandatory: false},
        {name: :quick_method_removal, klass: Filter::QuickMethodRemoval, mandatory: false},
        {name: :compress_tree, klass: Filter::CompressTree, mandatory: false},
        {name: :js_tree, klass: Filter::JsTree, mandatory: true},
      ]

      filters = filter_map.map do |f|
        name, klass, mandatory = f.values_at :name, :klass, :mandatory
        opts = params[:filters][name.to_s]
        opts = HashWithIndifferentAccess.new(opts) if opts

        if mandatory
          klass.new(opts || {})
        elsif opts
          klass.new(opts)
        end
      end.compact

      filtered = filters.reduce(run) {|memo, filter| filter.filter(memo, frames) }

      content_type 'application/json'
      Oj.dump(filtered, mode: :compat)
    end
  end
end
