# Test the basics of service status interrogation
#
# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# License:: MIT (see the file LICENSE)
#

require 'testbase'
require 'sys/sv/svdir'

class TC_down_0_normd_nowant < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal(@svdir.down?, true)
  end

  def test_want_up?
    assert_equal(@svdir.want_up?, false)
  end

  def test_pid
    assert(@svdir.pid.nil?)
  end

  def test_want_down?
    assert_equal(@svdir.want_down?, false)
  end

  def test_normally_up?
    assert_equal(@svdir.normally_up?, false)
  end

  def test_paused?
    assert_equal(@svdir.paused?, false)
  end

  def test_normally_down?
    assert_equal(@svdir.normally_down?, true)
  end

  def test_up?
    assert_equal(@svdir.up?, false)
  end

  def test_downtime
    assert_elapsed_time(@svdir.downtime)
  end

  def test_uptime
    assert(@svdir.uptime.nil?, "uptime was not nil")
  end
end


class TC_down_0_normu_nowant < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal(@svdir.down?, true)
  end

  def test_want_up?
    assert_equal(@svdir.want_up?, false)
  end

  def test_pid
    assert(@svdir.pid.nil?)
  end

  def test_want_down?
    assert_equal(@svdir.want_down?, false)
  end

  def test_normally_up?
    assert_equal(@svdir.normally_up?, true)
  end

  def test_paused?
    assert_equal(@svdir.paused?, false)
  end

  def test_normally_down?
    assert_equal(@svdir.normally_down?, false)
  end

  def test_up?
    assert_equal(@svdir.up?, false)
  end

  def test_downtime
    assert_elapsed_time(@svdir.downtime)
  end

  def test_uptime
    assert(@svdir.uptime.nil?, "uptime was not nil")
  end
end


class TC_up_12526_normu_wantd < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal(@svdir.down?, false)
  end

  def test_want_up?
    assert_equal(@svdir.want_up?, false)
  end

  def test_pid
    assert_equal(@svdir.pid, 12526)
  end

  def test_want_down?
    assert_equal(@svdir.want_down?, true)
  end

  def test_normally_up?
    assert_equal(@svdir.normally_up?, true)
  end

  def test_paused?
    assert_equal(@svdir.paused?, false)
  end

  def test_normally_down?
    assert_equal(@svdir.normally_down?, false)
  end

  def test_up?
    assert_equal(@svdir.up?, true)
  end

  def test_downtime
    assert(@svdir.downtime.nil?, "downtime was not nil")
  end

  def test_uptime
    assert_elapsed_time(@svdir.uptime)
  end
end


class TC_up_12581_normd_wantd_paused < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal(@svdir.down?, false)
  end

  def test_want_up?
    assert_equal(@svdir.want_up?, false)
  end

  def test_pid
    assert_equal(@svdir.pid, 12581)
  end

  def test_want_down?
    assert_equal(@svdir.want_down?, true)
  end

  def test_normally_up?
    assert_equal(@svdir.normally_up?, false)
  end

  def test_paused?
    assert_equal(@svdir.paused?, true)
  end

  def test_normally_down?
    assert_equal(@svdir.normally_down?, true)
  end

  def test_up?
    assert_equal(@svdir.up?, true)
  end

  def test_downtime
    assert(@svdir.downtime.nil?, "downtime was not nil")
  end

  def test_uptime
    assert_elapsed_time(@svdir.uptime)
  end
end


class TC_up_12581_normu_wantd_paused < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal(@svdir.down?, false)
  end

  def test_want_up?
    assert_equal(@svdir.want_up?, false)
  end

  def test_pid
    assert_equal(@svdir.pid, 12581)
  end

  def test_want_down?
    assert_equal(@svdir.want_down?, true)
  end

  def test_normally_up?
    assert_equal(@svdir.normally_up?, true)
  end

  def test_paused?
    assert_equal(@svdir.paused?, true)
  end

  def test_normally_down?
    assert_equal(@svdir.normally_down?, false)
  end

  def test_up?
    assert_equal(@svdir.up?, true)
  end

  def test_downtime
    assert(@svdir.downtime.nil?, "downtime was not nil")
  end

  def test_uptime
    assert_elapsed_time(@svdir.uptime)
  end
end


class TC_up_12816_normd_nowant < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal(@svdir.down?, false)
  end

  def test_want_up?
    assert_equal(@svdir.want_up?, false)
  end

  def test_pid
    assert_equal(@svdir.pid, 12816)
  end

  def test_want_down?
    assert_equal(@svdir.want_down?, false)
  end

  def test_normally_up?
    assert_equal(@svdir.normally_up?, false)
  end

  def test_paused?
    assert_equal(@svdir.paused?, false)
  end

  def test_normally_down?
    assert_equal(@svdir.normally_down?, true)
  end

  def test_up?
    assert_equal(@svdir.up?, true)
  end

  def test_downtime
    assert(@svdir.downtime.nil?, "downtime was not nil")
  end

  def test_uptime
    assert_elapsed_time(@svdir.uptime)
  end
end


class TC_up_12816_normu_nowant < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal(@svdir.down?, false)
  end

  def test_want_up?
    assert_equal(@svdir.want_up?, false)
  end

  def test_pid
    assert_equal(@svdir.pid, 12816)
  end

  def test_want_down?
    assert_equal(@svdir.want_down?, false)
  end

  def test_normally_up?
    assert_equal(@svdir.normally_up?, true)
  end

  def test_paused?
    assert_equal(@svdir.paused?, false)
  end

  def test_normally_down?
    assert_equal(@svdir.normally_down?, false)
  end

  def test_up?
    assert_equal(@svdir.up?, true)
  end

  def test_downtime
    assert(@svdir.downtime.nil?, "downtime was not nil")
  end

  def test_uptime
    assert_elapsed_time(@svdir.uptime)
  end
end


class TC_up_12868_normd_wantu < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal(@svdir.down?, false)
  end

  def test_want_up?
    assert_equal(@svdir.want_up?, true)
  end

  def test_pid
    assert_equal(@svdir.pid, 12868)
  end

  def test_want_down?
    assert_equal(@svdir.want_down?, false)
  end

  def test_normally_up?
    assert_equal(@svdir.normally_up?, false)
  end

  def test_paused?
    assert_equal(@svdir.paused?, false)
  end

  def test_normally_down?
    assert_equal(@svdir.normally_down?, true)
  end

  def test_up?
    assert_equal(@svdir.up?, true)
  end

  def test_downtime
    assert(@svdir.downtime.nil?, "downtime was not nil")
  end

  def test_uptime
    assert_elapsed_time(@svdir.uptime)
  end
end


class TC_up_12868_normd_wantu_paused < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal(@svdir.down?, false)
  end

  def test_want_up?
    assert_equal(@svdir.want_up?, true)
  end

  def test_pid
    assert_equal(@svdir.pid, 12868)
  end

  def test_want_down?
    assert_equal(@svdir.want_down?, false)
  end

  def test_normally_up?
    assert_equal(@svdir.normally_up?, false)
  end

  def test_paused?
    assert_equal(@svdir.paused?, true)
  end

  def test_normally_down?
    assert_equal(@svdir.normally_down?, true)
  end

  def test_up?
    assert_equal(@svdir.up?, true)
  end

  def test_downtime
    assert(@svdir.downtime.nil?, "downtime was not nil")
  end

  def test_uptime
    assert_elapsed_time(@svdir.uptime)
  end
end


class TC_up_12868_normu_wantu < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal(@svdir.down?, false)
  end

  def test_want_up?
    assert_equal(@svdir.want_up?, true)
  end

  def test_pid
    assert_equal(@svdir.pid, 12868)
  end

  def test_want_down?
    assert_equal(@svdir.want_down?, false)
  end

  def test_normally_up?
    assert_equal(@svdir.normally_up?, true)
  end

  def test_paused?
    assert_equal(@svdir.paused?, false)
  end

  def test_normally_down?
    assert_equal(@svdir.normally_down?, false)
  end

  def test_up?
    assert_equal(@svdir.up?, true)
  end

  def test_downtime
    assert(@svdir.downtime.nil?, "downtime was not nil")
  end

  def test_uptime
    assert_elapsed_time(@svdir.uptime)
  end
end


class TC_up_12868_normu_wantu_paused < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal(@svdir.down?, false)
  end

  def test_want_up?
    assert_equal(@svdir.want_up?, true)
  end

  def test_pid
    assert_equal(@svdir.pid, 12868)
  end

  def test_want_down?
    assert_equal(@svdir.want_down?, false)
  end

  def test_normally_up?
    assert_equal(@svdir.normally_up?, true)
  end

  def test_paused?
    assert_equal(@svdir.paused?, true)
  end

  def test_normally_down?
    assert_equal(@svdir.normally_down?, false)
  end

  def test_up?
    assert_equal(@svdir.up?, true)
  end

  def test_downtime
    assert(@svdir.downtime.nil?, "downtime was not nil")
  end

  def test_uptime
    assert_elapsed_time(@svdir.uptime)
  end
end


class TC_up_16464_normd_wantd < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal(@svdir.down?, false)
  end

  def test_want_up?
    assert_equal(@svdir.want_up?, false)
  end

  def test_pid
    assert_equal(@svdir.pid, 16464)
  end

  def test_want_down?
    assert_equal(@svdir.want_down?, true)
  end

  def test_normally_up?
    assert_equal(@svdir.normally_up?, false)
  end

  def test_paused?
    assert_equal(@svdir.paused?, false)
  end

  def test_normally_down?
    assert_equal(@svdir.normally_down?, true)
  end

  def test_up?
    assert_equal(@svdir.up?, true)
  end

  def test_downtime
    assert(@svdir.downtime.nil?, "downtime was not nil")
  end

  def test_uptime
    assert_elapsed_time(@svdir.uptime)
  end
end
