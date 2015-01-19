module Stackprofiler
  class RunCodeCache
    extend MethodSource::CodeHelpers

    def initialize profile
      @profile = profile
    end

    def source_helper(source_location, name=nil)
      file, line = *source_location
      file_cache = @profile[:files] || []

      if file_cache.include? file
        file_data = @profile[:files][file]
        self.class.expression_at(file_data, line)
      else
        MethodSource::source_helper(source_location, name)
      end
    end
  end
end
