require 'oj'
require 'tree'
require 'coderay'
require 'objspace'
require 'stackprof'
require 'sinatra/base'
require 'active_support/all'
require 'sinatra/content_for'

require 'stackprofiler/version'
require 'stackprofiler/web_ui'
require 'stackprofiler/middleware'
require 'stackprofiler/data_collector'
require 'stackprofiler/run_data_source'
require 'stackprofiler/utils'

require 'stackprofiler/filters/js_tree'
require 'stackprofiler/filters/build_tree'
require 'stackprofiler/filters/gem_removal'
require 'stackprofiler/filters/rebase_stack'
require 'stackprofiler/filters/compress_tree'
require 'stackprofiler/filters/frame_regex_removal'
require 'stackprofiler/filters/quick_method_elision'

module Stackprofiler
  # Your code goes here...
end
