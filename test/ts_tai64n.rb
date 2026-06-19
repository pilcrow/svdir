#!/usr/bin/env ruby
#
# Test TAI64N timestamp parsing and the nanosecond field
#
# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2026 Mike Pomraning
# License:: MIT (see the file LICENSE)
#

require 'testbase'
require 'sys/sv/statusbytes'

class TC_Tai64N < Test::Unit::TestCase
  include Sys::Sv

  # Build an 18-byte status buffer from a raw TAI64N timestamp.
  # The 12-byte TAI64N label stores (tai64_secs) as an 8-byte big-endian
  # uint64 split into hi/lo 32-bit words, plus nanoseconds as 4 bytes.
  def make_status(tai64_hi, tai64_lo, nano, pid = 0, pause = 0, want = "\x00")
    [tai64_hi, tai64_lo, nano].pack('NNN') +
    [pid].pack('V') + [pause].pack('c') + [want].pack('a')
  end

  # The on-wire TAI64 value is:  tai64 = unix_epoch + TAI_EPOCH
  # where TAI_EPOCH = 2^62 + 10 (the TAI representation of Unix time 0).
  # StatusBytes reverses this:  unix_epoch = tai64 - TAI_EPOCH.
  def tai64_from_unix(unix_epoch)
    unix_epoch + StatusBytes::TAI_EPOCH
  end

  # split a 64-bit value into hi/lo 32-bit halves for big-endian packing
  def hi32(val)
    val >> 32
  end

  def lo32(val)
    val & 0xFFFFFFFF
  end

  # Unix epoch 2009-02-13 23:31:20 +0000 = 1234567880
  def test_known_timestamp
    tai64 = tai64_from_unix(1234567880)
    buf = make_status(hi32(tai64), lo32(tai64), 500_000_000)
    sb  = StatusBytes.new(buf)
    assert_in_delta(1234567880.5, sb.epoch, 0.000_001)
  end

  # Zero nanoseconds
  def test_zero_nano
    tai64 = tai64_from_unix(1000)
    buf = make_status(hi32(tai64), lo32(tai64), 0)
    sb  = StatusBytes.new(buf)
    assert_in_delta(1000.0, sb.epoch, 0.000_001)
  end

  # Max nanoseconds (999999999)
  def test_max_nano
    tai64 = tai64_from_unix(1000)
    buf = make_status(hi32(tai64), lo32(tai64), 999_999_999)
    sb  = StatusBytes.new(buf)
    assert_in_delta(1000.999999999, sb.epoch, 0.000_001)
  end

  # elapsed returns a positive Float (epoch 0 edge case)
  def test_elapsed
    tai64 = tai64_from_unix(0)
    buf = make_status(hi32(tai64), lo32(tai64), 500_000_000)
    sb  = StatusBytes.new(buf)
    assert_kind_of(Float, sb.elapsed)
    assert(sb.elapsed > 0)
  end
end
