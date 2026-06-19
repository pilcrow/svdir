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

  # The epoch conversion from TAI64 to Unix is:
  #   unix = tai64 - 2^62 - 10
  # where +10 is the fixed TAI-UTC offset at the epoch.
  #
  # For a desired Unix timestamp U, the stored lo32 = U + 10.
  # hi32 is always 0x40000000 (= 2^30) for any post-epoch time.

  # Unix epoch 2009-02-13 23:31:20 +0000 = 1234567880.
  # lo32 = 1234567880 + 10 = 1234567890 = 0x499602D2
  def test_known_timestamp
    buf = make_status(0x40000000, 0x499602D2, 500_000_000)
    sb  = StatusBytes.new(buf)
    assert_in_delta(1234567880.5, sb.epoch, 0.000_001)
  end

  # Zero nanoseconds at Unix epoch 1000
  def test_zero_nano
    buf = make_status(0x40000000, 1010, 0) # lo32 = 1000 + 10 = 1010
    sb  = StatusBytes.new(buf)
    assert_in_delta(1000.0, sb.epoch, 0.000_001)
  end

  # Max nanoseconds at Unix epoch 1000
  def test_max_nano
    buf = make_status(0x40000000, 1010, 999_999_999)
    sb  = StatusBytes.new(buf)
    assert_in_delta(1000.999999999, sb.epoch, 0.000_001)
  end

  # Verify that elapsed returns a positive Float (time-dependent)
  def test_elapsed
    buf = make_status(0x40000000, 10, 500_000_000)
    sb  = StatusBytes.new(buf)
    assert_kind_of(Float, sb.elapsed)
    assert(sb.elapsed > 0)
  end
end
