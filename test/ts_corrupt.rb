# Test the basics of service status interrogation
#
# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# License:: MIT (see the file LICENSE)
#

require 'testbase'
require 'sys/sv/svdir'

class TC_corrupt_normu < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_raise(::Errno::EPROTO) do
      @svdir.down?
    end
  end

  def test_want_up?
    assert_raise(::Errno::EPROTO) do
      @svdir.want_up?
    end
  end

  def test_pid
    assert_raise(::Errno::EPROTO) do
      @svdir.pid
    end
  end

  def test_want_down?
    assert_raise(::Errno::EPROTO) do
      @svdir.want_down?
    end
  end

  def test_normally_up?
    assert(@svdir.normally_up?, "normally_up? should still succeed even on corrupted SvDir")
  end

  def test_paused?
    assert_raise(::Errno::EPROTO) do
      @svdir.paused?
    end
  end

  def test_normally_down?
    assert(!@svdir.normally_down?, "normally_down? should still succeed even on corrupted SvDir")
  end

  def test_up?
    assert_raise(::Errno::EPROTO) do
      @svdir.up?
    end
  end

  def test_downtime
    assert_raise(::Errno::EPROTO) do
      @svdir.downtime
    end
  end

  def test_uptime
    assert_raise(::Errno::EPROTO) do
      @svdir.uptime
    end
  end
end

class TC_corrupt_normd < Test::Unit::TestCase
  include_fixture :PrefabSvDir

  def test_down?
    assert_raise(::Errno::EPROTO) do
      @svdir.down?
    end
  end

  def test_want_up?
    assert_raise(::Errno::EPROTO) do
      @svdir.want_up?
    end
  end

  def test_pid
    assert_raise(::Errno::EPROTO) do
      @svdir.pid
    end
  end

  def test_want_down?
    assert_raise(::Errno::EPROTO) do
      @svdir.want_down?
    end
  end

  def test_normally_up?
    assert(!@svdir.normally_up?, "normally_up? should still succeed even on corrupted SvDir")
  end

  def test_paused?
    assert_raise(::Errno::EPROTO) do
      @svdir.paused?
    end
  end

  def test_normally_down?
    assert(@svdir.normally_down?, "normally_down? should still succeed even on corrupted SvDir")
  end

  def test_up?
    assert_raise(::Errno::EPROTO) do
      @svdir.up?
    end
  end

  def test_downtime
    assert_raise(::Errno::EPROTO) do
      @svdir.downtime
    end
  end

  def test_uptime
    assert_raise(::Errno::EPROTO) do
      @svdir.uptime
    end
  end
end

# Zero-byte status files take a slightly different code path to reach EPROTO
class TC_corrupt_zero_normd < TC_corrupt_normd; end
class TC_corrupt_zero_normu < TC_corrupt_normu; end
