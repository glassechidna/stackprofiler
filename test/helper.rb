require 'minitest/autorun'
require 'minitest/power_assert'

require 'stackprofiler'

def profile_run
  @run ||= get_profile_run
end

def get_profile_run
  path = File.expand_path '../profile.json.gz', __FILE__
  data =  Zlib::GzipReader::open path
  profile = Oj.load data
  run = Stackprofiler::Run.new 'n/a', profile, Time.now
end
