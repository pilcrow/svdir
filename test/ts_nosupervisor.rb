#!/usr/bin/env ruby
# 
# Handle the case of no supervisor running
#
# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# License:: MIT (see the file LICENSE)
#

$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'testbase'
require 'sys/sv/svdir'

class TestSvcNoSupervisor < Test::Unit::TestCase

  include_fixture :TempSvDir

  def setup
    ret = super
    # close .../control and .../ok
    fifo_control.close
    fifo_ok.close
    ret
  end

  # Verify that unknown signal arguments still throw ArgumentError
  def test_signal_unknown
    [ :invalid, 'invalid' ].each do |bogus|
      assert_raise ArgumentError do
        @svdir.signal bogus
      end
    end
  end

  # Verify that a known signal generates ENXIO
  def test_signal_up
    [ :up, 'up' ].each do |c|
      assert_raise Errno::ENXIO do
        @svdir.signal c
      end
    end
  end

  # Verify svok? == false
  def test_not_svok
    assert @svdir.svok? == false
  end

  # Verify that the StatusBytes delegates throw ENXIO
  [:down?, :downtime, :paused?, :pid, :up?, :uptime, :want_down?, :want_up?].
  each do |m|
    define_method "test_err_#{m}" do
      assert_raise Errno::ENXIO do
        @svdir.__send__(m)
      end
    end
  end

  # Verify that normally_up? still functions
  def test_normally_up?
    assert_nothing_raised do
      @svdir.normally_up?
    end
  end

  # Verify that normally_down? still functions
  def test_normally_down?
    assert_nothing_raised do
      @svdir.normally_down?
    end
  end
 
  # Verify that log() still functions
  def test_normally_down?
    assert_nothing_raised do
      @svdir.log
    end
  end

end
