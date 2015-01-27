require_relative './helper'

class TestBuildTree < MiniTest::Test
  def test_tree_size
    filter = Stackprofiler::Filter::BuildTree.new
    run = profile_run
    root = filter.filter run, run

    semi_cyclic = root.each.take(36).drop(1)
    names = semi_cyclic.map do |node|
      run.profile[:frames][node.name][:name]
    end

    # indirect recursion
    assert { names[30] == 'Sinatra::Base#invoke' }
    assert { names[34] == 'Sinatra::Base#invoke' }

    # direct recursion
    assert { names[13] == 'Rack::Protection::Base#call' }
    assert { names[14] == 'Rack::Protection::Base#call' }
  end
end
