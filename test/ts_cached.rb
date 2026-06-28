# frozen_string_literal: true

# Test SvDir::Cached lazy-snapshot proxy via SvDir#cached
#
# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2026 Mike Pomraning
# License:: MIT (see the file LICENSE)
#

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'testbase'
require 'sys/sv/svdir'
require 'fileutils'

# ---------------------------------------------------------------------------
# PrefabSvDir-style tests — static fixture directories, no supervisor.
# Each test exercises the cached proxy against a known status file.
# ---------------------------------------------------------------------------

class TC_cached_up_12526_normu_wantd < Test::Unit::TestCase
  include_fixture :PrefabSvDir
  PREFAB_FIXTURE = 'up-12526-normu-wantd'

  def test_consistency
    @svdir.cached do |c|
      assert_equal 12_526, c.pid
      assert c.up?
      assert !c.down?
      assert !c.want_up?
      assert c.want_down?
      assert !c.paused?
      assert c.normally_up?
      assert !c.normally_down?
      assert_elapsed_time c.uptime
      assert_nil c.downtime
      assert_equal 18, c.raw_status.bytesize
      assert_nil c.run_state
      assert_nil c.term_sent?
    end
  end
end

class TC_cached_down_0_normd_nowant < Test::Unit::TestCase
  include_fixture :PrefabSvDir
  PREFAB_FIXTURE = 'down-0-normd-nowant'

  def test_consistency
    @svdir.cached do |c|
      assert_nil c.pid
      assert c.down?
      assert !c.up?
      assert !c.want_up?
      assert !c.want_down?
      assert !c.normally_up?
      assert c.normally_down?
      assert_nil c.uptime
      assert_elapsed_time c.downtime
    end
  end
end

class TC_cached_paused < Test::Unit::TestCase
  include_fixture :PrefabSvDir
  PREFAB_FIXTURE = 'up-12581-normd-wantd-paused'

  def test_consistency
    @svdir.cached do |c|
      assert_equal 12_581, c.pid
      assert c.up?
      assert c.paused?
      assert c.want_down?
      assert !c.want_up?
    end
  end
end

class TC_cached_daemontools_18byte < Test::Unit::TestCase
  include_fixture :PrefabSvDir
  PREFAB_FIXTURE = 'up-16464-normd-wantd'

  def test_raw_status_runit_nil
    @svdir.cached do |c|
      assert_equal 18, c.raw_status.bytesize
      assert_nil c.run_state
      assert_nil c.term_sent?
    end
  end
end

class TC_cached_runit_run < Test::Unit::TestCase
  include_fixture :PrefabSvDir
  PREFAB_FIXTURE = 'runit-run-12345-normu-wantu'

  def test_runit_state
    @svdir.cached do |c|
      assert_equal 12_345, c.pid
      assert c.up?
      assert_equal :run, c.run_state
      assert !c.term_sent?
      assert c.normally_up?
    end
  end
end

class TC_cached_runit_finish < Test::Unit::TestCase
  include_fixture :PrefabSvDir
  PREFAB_FIXTURE = 'runit-finish-12345-normu-nowant'

  def test_runit_finish_state
    @svdir.cached do |c|
      assert_equal 12_345, c.pid
      assert c.up?          # finish script counts as up
      assert_equal :finish, c.run_state
      assert c.want_down?   # finish state implies want down
    end
  end
end

class TC_cached_runit_term_sent < Test::Unit::TestCase
  include_fixture :PrefabSvDir
  PREFAB_FIXTURE = 'runit-run-12345-normd-wantu-term'

  def test_term_sent
    @svdir.cached do |c|
      assert c.term_sent?
      assert_equal 12_345, c.pid
    end
  end
end

# ---------------------------------------------------------------------------
# is_a? / kind_of? and API shape
# ---------------------------------------------------------------------------

class TC_cached_is_a < Test::Unit::TestCase
  include_fixture :PrefabSvDir
  PREFAB_FIXTURE = 'up-12526-normu-wantd'

  def test_is_a
    c = @svdir.cached
    assert c.is_a?(Sys::Sv::SvDir)
    assert c.kind_of?(Sys::Sv::SvDir)
  end

  def test_block_returns_value
    ret = @svdir.cached { |_c| :from_block }
    assert_equal :from_block, ret
  end

  def test_no_block_returns_cached
    c = @svdir.cached
    assert c.is_a?(Sys::Sv::SvDir)
  end

  def test_multiple_cached_calls_independent
    c1 = @svdir.cached
    c2 = @svdir.cached
    assert_equal c1.pid, c2.pid          # both read the same static file
    assert c1.is_a?(Sys::Sv::SvDir)
    assert c2.is_a?(Sys::Sv::SvDir)
  end

  def test_cached_idempotent
    c1 = @svdir.cached
    c2 = c1.cached
    assert c2.is_a?(Sys::Sv::SvDir)
  end
end

# ---------------------------------------------------------------------------
# TempSvDir-based tests — real FIFOs, live supervisor simulation
# ---------------------------------------------------------------------------

class TC_cached_lazy < Test::Unit::TestCase
  include_fixture :TempSvDir

  STATUS_BYTES = [0x40000000, 0x6562E70A, 500_000_000,
                  11_111, 0, 'u'].pack('NNNVca')

  def test_lazy_no_io_on_create
    assert_nothing_raised do
      @svdir.cached
    end
  end

  def test_first_access_triggers_read
    c = @svdir.cached
    assert_equal 11_111, c.pid
  end

  def test_cached_survives_file_mutation
    c = @svdir.cached
    assert_equal 11_111, c.pid

    # Change the file behind our back
    modified = [0x40000000, 0x6562E70A, 500_000_000,
                99_999, 0, 'u'].pack('NNNVca')
    File.write(status_path, modified)

    # Cached still sees original value
    assert_equal 11_111, c.pid

    # Fresh non-cached SvDir reads the new value
    fresh = Sys::Sv::SvDir.new(@svdirname)
    assert_equal 99_999, fresh.pid
  end

  def test_uptime_uses_cached_epoch
    c = @svdir.cached
    u = c.uptime
    assert_kind_of Float, u
    # Calling a second time should still give a positive float
    u2 = c.uptime
    assert_kind_of Float, u2
    assert u2 >= u  # wall clock advanced (or equal on same tick)
  end
end

class TC_cached_mutable < Test::Unit::TestCase
  include_fixture :TempSvDir

  STATUS_BYTES = [0x40000000, 0x6562E70A, 500_000_000,
                  12_345, 0, 'u'].pack('NNNVca')

  def test_signal_up
    @svdir.cached do |c|
      c.signal(:up)
      assert_equal 'u', fifo_control.sysread(1)
    end
  end

  def test_signal_down
    @svdir.cached do |c|
      c.signal(:down)
      assert_equal 'd', fifo_control.sysread(1)
    end
  end

  def test_signal_exit
    @svdir.cached do |c|
      c.signal(:exit)
      assert_equal 'x', fifo_control.sysread(1)
    end
  end

  def test_normally_up_bang_removes_down
    FileUtils.touch(File.join(@svdirname, 'down'))
    assert File.exist?(File.join(@svdirname, 'down'))

    @svdir.cached do |c|
      ret = c.normally_up!
      assert_equal true, ret
      assert !File.exist?(File.join(@svdirname, 'down'))
    end

    assert @svdir.normally_up?
  end

  def test_normally_down_bang_creates_down
    assert !File.exist?(File.join(@svdirname, 'down'))

    @svdir.cached do |c|
      ret = c.normally_down!
      assert_equal true, ret
      assert File.exist?(File.join(@svdirname, 'down'))
    end

    assert @svdir.normally_down?
  end

  def test_normally_up_bang_noop
    assert !File.exist?(File.join(@svdirname, 'down'))

    @svdir.cached do |c|
      assert_nil c.normally_up!
    end
  end

  def test_normally_down_bang_noop
    FileUtils.touch(File.join(@svdirname, 'down'))

    @svdir.cached do |c|
      assert_nil c.normally_down!
    end
  end
end

class TC_cached_error < Test::Unit::TestCase
  include_fixture :TempSvDir

  STATUS_BYTES = [0x40000000, 0x6562E70A, 500_000_000,
                  12_345, 0, 'u'].pack('NNNVca')

  def setup
    ret = super
    # Close FIFOs to simulate absent supervisor
    fifo_control.close
    fifo_ok.close
    ret
  end

  def test_enxio_on_first_status_access
    c = @svdir.cached
    assert_raise Errno::ENXIO do
      c.pid
    end
  end

  def test_enxio_not_cached
    c = @svdir.cached
    assert_raise Errno::ENXIO do
      c.pid
    end
    # Error is not cached — second call retries and also raises
    assert_raise Errno::ENXIO do
      c.pid
    end
  end

  def test_normally_down_still_works
    c = @svdir.cached
    assert_nothing_raised do
      c.normally_down?
    end
  end

  def test_signal_still_works
    @svdir.cached do |c|
      assert_raise Errno::ENXIO do
        c.signal(:up)
      end
    end
  end
end

class TC_cached_corrupt < Test::Unit::TestCase
  include_fixture :TempSvDir

  # 17 bytes — too short for 18 or 20, triggers EPROTO
  STATUS_BYTES = "\x00" * 17

  def test_epetro_on_first_access
    c = @svdir.cached
    assert_raise Errno::EPROTO do
      c.pid
    end
  end

  def test_epetro_not_cached
    c = @svdir.cached
    assert_raise Errno::EPROTO do
      c.pid
    end
    # EPROTO not cached — retry re-reads the same corrupt file
    assert_raise Errno::EPROTO do
      c.pid
    end
  end

  def test_normally_down_ignores_status
    c = @svdir.cached
    assert_nothing_raised do
      c.normally_down?
    end
  end
end

class TC_cached_nesting < Test::Unit::TestCase
  include_fixture :TempSvDir

  STATUS_BYTES = [0x40000000, 0x6562E70A, 500_000_000,
                  55_555, 0, 'u'].pack('NNNVca')

  def test_nested_independent_cache
    c1 = @svdir.cached
    assert_equal 55_555, c1.pid

    # Change the file
    modified = [0x40000000, 0x6562E70A, 500_000_000,
                66_666, 0, 'u'].pack('NNNVca')
    File.write(status_path, modified)

    # c1 sees original (cached)
    assert_equal 55_555, c1.pid

    # c2 is a new Cached — reads fresh
    c2 = c1.cached
    assert_equal 66_666, c2.pid

    # c1 unchanged
    assert_equal 55_555, c1.pid
  end
end

class TC_cached_log < Test::Unit::TestCase
  include_fixture :TempSvDir

  STATUS_BYTES = [0x40000000, 0x6562E70A, 500_000_000,
                  77_777, 0, 'u'].pack('NNNVca')
  LOG_STATUS_BYTES = [0x40000001, 0x12345678, 250_000_000,
                      88_888, 0, 'u'].pack('NNNVca').freeze

  def setup
    ret = super
    # Create a log subdirectory with its own supervise/status
    log_sv = File.join(@svdirname, 'log', 'supervise')
    FileUtils.mkdir_p(log_sv)
    File.write(File.join(log_sv, 'status'), self.class::LOG_STATUS_BYTES)
    ret
  end

  def test_log_returns_cached
    c = @svdir.cached
    log_c = c.log
    assert_not_nil log_c
    assert log_c.is_a?(Sys::Sv::SvDir::Cached)
  end

  def test_log_independent_cache
    c = @svdir.cached
    log_c = c.log

    # Base and log have different pids
    assert_equal 77_777, c.pid
    assert_equal 88_888, log_c.pid
  end
end

class TC_cached_svok < Test::Unit::TestCase
  include_fixture :TempSvDir

  STATUS_BYTES = [0x40000000, 0x6562E70A, 500_000_000,
                  12_345, 0, 'u'].pack('NNNVca')

  def test_svok_not_cached
    c = @svdir.cached
    assert c.svok?  # FIFO ok is held open by fixture

    fifo_ok.close
    # svok? should now fail — it's not cached
    assert !c.svok?
  end
end
