module Stackprofiler
  class Middleware
    def initialize(app, options = {})
      mid = Rack::Builder.new do
        use Rack::Deflater
        run WebUI
      end

      @app = Rack::URLMap.new({'/__stackprofiler' => mid, '/' => DataCollector.new(app)})
      @options = options
    end

    def call(env)
      @app.call env
    end
  end
end

