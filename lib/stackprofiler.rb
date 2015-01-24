require 'oj'
require 'tree'
require 'objspace'
require 'method_source'
require 'sinatra/base'
require 'active_support/all'
require 'sinatra/content_for'
require 'net/http'

require 'stackprofiler/web_ui'
require 'stackprofiler/run_data_source'
require 'stackprofiler/run_code_cache'
require 'stackprofiler/utils'

require 'stackprofiler/filters/js_tree'
require 'stackprofiler/filters/build_tree'
require 'stackprofiler/filters/gem_removal'
require 'stackprofiler/filters/rebase_stack'
require 'stackprofiler/filters/compress_tree'
require 'stackprofiler/filters/frame_regex_removal'
require 'stackprofiler/filters/quick_method_removal'

module Stackprofiler
end
