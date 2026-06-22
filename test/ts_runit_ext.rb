# frozen_string_literal: true

# Test runit 20-byte status file extensions.
# Like existing prefab fixtures, these use static (no supervisor) dirs.
#
# The runit format extends the original 18-byte daemontools status with
# two additional bytes at offsets 18 and 19:
#   off 18  got TERM     0/1      non-zero means SIGTERM has been sent
#   off 19  state        0/1/2    0 = down, 1 = running, 2 = finish
#
# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2026 Mike Pomraning
# License:: MIT (see the file LICENSE)
#

require 'testbase'
require 'sys/sv/statusbytes'

class TC_runit_down_0_normd_nowant < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal true, @svdir.down?
  end

  def test_up?
    assert_equal false, @svdir.up?
  end

  def test_run_state
    assert_equal :down, @svdir.run_state
  end

  def test_term_sent?
    assert_equal false, @svdir.term_sent?
  end

  def test_pid
    assert_nil @svdir.pid
  end

  def test_want_up?
    assert_equal false, @svdir.want_up?
  end

  def test_want_down?
    assert_equal true, @svdir.want_down?
  end

  def test_normally_up?
    assert_equal false, @svdir.normally_up?
  end

  def test_normally_down?
    assert_equal true, @svdir.normally_down?
  end

  def test_paused?
    assert_equal false, @svdir.paused?
  end

  def test_raw_status
    expected = File.binread(File.join(@svdir.path, 'supervise', 'status'))
    assert_equal 20, expected.bytesize
    assert_equal expected, @svdir.raw_status
  end

  def test_uptime
    assert_nil @svdir.uptime
  end

  def test_downtime
    assert_elapsed_time @svdir.downtime
  end
end

class TC_runit_run_12345_normu_wantu < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal false, @svdir.down?
  end

  def test_up?
    assert_equal true, @svdir.up?
  end

  def test_run_state
    assert_equal :run, @svdir.run_state
  end

  def test_term_sent?
    assert_equal false, @svdir.term_sent?
  end

  def test_pid
    assert_equal 12_345, @svdir.pid
  end

  def test_want_up?
    assert_equal true, @svdir.want_up?
  end

  def test_want_down?
    assert_equal false, @svdir.want_down?
  end

  def test_normally_up?
    assert_equal true, @svdir.normally_up?
  end

  def test_normally_down?
    assert_equal false, @svdir.normally_down?
  end

  def test_paused?
    assert_equal false, @svdir.paused?
  end

  def test_raw_status
    expected = File.binread(File.join(@svdir.path, 'supervise', 'status'))
    assert_equal 20, expected.bytesize
    assert_equal expected, @svdir.raw_status
  end

  def test_uptime
    assert_elapsed_time @svdir.uptime
  end

  def test_downtime
    assert_nil @svdir.downtime
  end
end

class TC_runit_run_12345_normd_wantu_paused < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal false, @svdir.down?
  end

  def test_run_state
    assert_equal :run, @svdir.run_state
  end

  def test_term_sent?
    assert_equal false, @svdir.term_sent?
  end

  def test_pid
    assert_equal 12_345, @svdir.pid
  end

  def test_want_up?
    assert_equal true, @svdir.want_up?
  end

  def test_paused?
    assert_equal true, @svdir.paused?
  end

  def test_normally_down?
    assert_equal true, @svdir.normally_down?
  end

  def test_normally_up?
    assert_equal false, @svdir.normally_up?
  end

  def test_raw_status
    expected = File.binread(File.join(@svdir.path, 'supervise', 'status'))
    assert_equal 20, expected.bytesize
    assert_equal expected, @svdir.raw_status
  end

  def test_up?
    assert_equal true, @svdir.up?
  end

  def test_want_down?
    assert_equal false, @svdir.want_down?
  end

  def test_uptime
    assert_elapsed_time @svdir.uptime
  end

  def test_downtime
    assert_nil @svdir.downtime
  end
end

class TC_runit_run_12345_normd_wantu_term < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal false, @svdir.down?
  end

  def test_run_state
    assert_equal :run, @svdir.run_state
  end

  def test_term_sent?
    assert_equal true, @svdir.term_sent?
  end

  def test_pid
    assert_equal 12_345, @svdir.pid
  end

  def test_want_up?
    assert_equal true, @svdir.want_up?
  end

  def test_paused?
    assert_equal false, @svdir.paused?
  end

  def test_normally_down?
    assert_equal true, @svdir.normally_down?
  end

  def test_up?
    assert_equal true, @svdir.up?
  end

  def test_want_down?
    assert_equal false, @svdir.want_down?
  end

  def test_normally_up?
    assert_equal false, @svdir.normally_up?
  end

  def test_uptime
    assert_elapsed_time @svdir.uptime
  end

  def test_downtime
    assert_nil @svdir.downtime
  end

  def test_raw_status
    expected = File.binread(File.join(@svdir.path, 'supervise', 'status'))
    assert_equal 20, expected.bytesize
    assert_equal expected, @svdir.raw_status
  end
end

class TC_runit_finish_12345_normu_nowant < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_equal false, @svdir.down?
  end

  def test_up?
    assert_equal true, @svdir.up?
  end

  def test_run_state
    assert_equal :finish, @svdir.run_state
  end

  def test_term_sent?
    assert_equal false, @svdir.term_sent?
  end

  def test_pid
    assert_equal 12_345, @svdir.pid
  end

  def test_want_up?
    assert_equal false, @svdir.want_up?
  end

  def test_want_down?
    assert_equal true, @svdir.want_down?
  end

  def test_normally_up?
    assert_equal true, @svdir.normally_up?
  end

  def test_normally_down?
    assert_equal false, @svdir.normally_down?
  end

  def test_paused?
    assert_equal false, @svdir.paused?
  end

  def test_raw_status
    expected = File.binread(File.join(@svdir.path, 'supervise', 'status'))
    assert_equal 20, expected.bytesize
    assert_equal expected, @svdir.raw_status
  end

  def test_uptime
    assert_elapsed_time @svdir.uptime
  end

  def test_downtime
    assert_nil @svdir.downtime
  end
end

# Verify backward-compatible nil behavior for the 18-byte daemontools format
class TestRunitBackwardCompat < Test::Unit::TestCase
  include Sys::Sv

  def test_18_byte_nil_fields
    buf = [0, 0, 0].pack('NNN') + [0, 0, "\x00"].pack('V c a')
    assert_equal 18, buf.bytesize
    sb = StatusBytes.new(buf)
    assert_nil sb.termflag
    assert_nil sb.runstate
  end

  def test_20_byte_has_fields
    buf = [0, 0, 0].pack('NNN') + [0, 0, "\x00", 0, 1].pack('V c a c c')
    assert_equal 20, buf.bytesize
    sb = StatusBytes.new(buf)
    assert_equal 0, sb.termflag
    assert_equal 1, sb.runstate
  end
end
