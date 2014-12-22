module Stackprofiler
  class DataCollector
    def initialize(app, options)
      @app = app

      pred = options[:predicate] || /profile=true/
      if pred.respond_to? :call
        @predicate = pred
      else
        regex = Regexp.new pred

        @predicate = proc do |env|
          req = Rack::Request.new env
          req.fullpath =~ regex
        end
      end

      @stackprof_opts = {mode: :wall, interval: 1000, raw: true}.merge(options[:stackprof] || {})
    end

    def call(env)
      if @predicate.call(env)
        out = nil
        profile = StackProf.run(@stackprof_opts) { out = @app.call env }

        req = Rack::Request.new env
        run = Run.new req.fullpath, profile, Time.now
        RunDataSource.runs << run

        out
      else
        @app.call env
      end
    end
  end

end
