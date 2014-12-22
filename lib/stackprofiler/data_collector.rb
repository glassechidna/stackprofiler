module Stackprofiler
  class DataCollector
    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      if env['QUERY_STRING'] =~ /profile=true/
        out = nil
        profile = StackProf.run(mode: :wall, interval: 1000, raw: true) { out = @app.call env }

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
