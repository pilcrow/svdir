# frozen_string_literal: true

# Verify SvDir#normally_up! and SvDir#normally_down!
#
# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2026 Mike Pomraning
# License:: MIT (see the file LICENSE)
#

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'testbase'
require 'sys/sv/svdir'
require 'fileutils'

class TestNormallyBang < Test::Unit::TestCase
  include_fixture :TempSvDir

  def down_path
    File.join(@svdirname, 'down')
  end

  # normally_up! removes an existing ./down
  def test_normally_up_bang_removes_down
    FileUtils.touch(down_path)
    assert File.exist?(down_path), 'sanity: down file should exist'

    ret = @svdir.normally_up!
    assert_equal true, ret

    assert !File.exist?(down_path), 'down file should have been removed'
    assert @svdir.normally_up?, 'normally_up? should return true'
    assert !@svdir.normally_down?, 'normally_down? should return false'
  end

  # normally_up! when no ./down exists => nil, no error
  def test_normally_up_bang_noop
    assert !File.exist?(down_path), 'sanity: no down file'

    ret = @svdir.normally_up!
    assert_nil ret

    assert !File.exist?(down_path), 'down file should still be absent'
  end

  # normally_down! creates an empty ./down
  def test_normally_down_bang_creates_down # rubocop:disable Metrics/AbcSize
    assert !File.exist?(down_path), 'sanity: no down file'

    ret = @svdir.normally_down!
    assert_equal true, ret

    assert File.exist?(down_path), 'down file should exist'
    assert File.empty?(down_path), 'down file should be empty'
    assert @svdir.normally_down?, 'normally_down? should return true'
    assert !@svdir.normally_up?, 'normally_up? should return false'
  end

  # normally_down! when ./down already exists => nil, no error
  def test_normally_down_bang_noop
    FileUtils.touch(down_path)
    assert File.exist?(down_path), 'sanity: down file should exist'

    ret = @svdir.normally_down!
    assert_nil ret

    assert File.exist?(down_path), 'down file should still exist'
  end

  # normally_down! with mode: creates file with given permissions
  def test_normally_down_bang_with_mode # rubocop:disable Metrics/MethodLength
    FileUtils.rm_f(down_path)
    old_umask = File.umask(0)
    begin
      ret = @svdir.normally_down!(mode: 0o644)
      assert_equal true, ret

      assert File.exist?(down_path), 'down file should exist'
      stat = File.stat(down_path)
      assert_equal 0o100644, stat.mode, 'mode should be 0644 (file)'
    ensure
      File.umask(old_umask)
    end
  end
end
