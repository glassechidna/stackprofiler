require 'oj'
require 'tree'
require 'coderay'
require 'objspace'
require 'stackprof'
require 'sinatra/base'
require 'sinatra/content_for'

require 'stackprofiler/version'
require 'stackprofiler/web_ui'
require 'stackprofiler/middleware'
require 'stackprofiler/data_collector'
require 'stackprofiler/run_data_source'

require 'stackprofiler/filters/js_tree'
require 'stackprofiler/filters/compress_tree'
require 'stackprofiler/filters/stackprofiler_elision'

module Stackprofiler
  # Your code goes here...
end
