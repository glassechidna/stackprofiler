module Stackprofiler
  class Middleware
    def initialize(app, options = {})
      @app = Rack::URLMap.new({'/__stackprofiler' => WebUI, '/' => DataCollector.new(app, options)})
      @options = options
    end

    def call(env)
      @app.call env
    end
  end
end

