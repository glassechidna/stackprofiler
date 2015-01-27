require_relative './helper'

class TestBuildTree < MiniTest::Test
  def test_stacks
    run = profile_run
    assert { run.stacks.length == 3072 } # got all samples

    stack_bases = run.stacks.map &:first
    assert { stack_bases == [70286637833860] * 3072 } # all samples from same thread

    assert { run.stacks.first.last == 70286629124680 } # correctly sized first sample
  end

  def test_gem_breakdown
    expected = ['(app)', 'rubytree', 'activesupport', 'stdlib', 'sinatra', 'backports']
    breakdown = profile_run.gem_breakdown

    assert { breakdown.keys == expected }
  end
end
