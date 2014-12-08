require 'stackprofiler'

run Rack::URLMap.new '/__stackprofiler' => Stackprofiler::WebUI.new(standalone: true)
