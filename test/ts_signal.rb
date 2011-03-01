#!/usr/bin/env ruby
# Verify that the .signal method issues the appropriate bytes to a
# svdir control FIFO.
#
# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# License:: MIT (see the file LICENSE)
#

$:.unshift File.join(File.dirname(__FILE__), "lib")

require 'testbase'
require 'sys/sv/svdir'

class TestSvcSignal < Test::Unit::TestCase

  include_fixture :TempSvDir

  # Verify that unknown signal arguments generate ArgumentError
  #
  def test_signal_unknown
    [ :invalid, 'invalid' ].each do |bogus|
      assert_raise ArgumentError do
        @svdir.signal bogus
      end
    end
  end

  # Verify each of the known signals, as symbols and strings
  # 
  def test_signal_up
    [:up, 'up'].each { |c| assert_expected_byte(c, 'u') }
  end

  def test_signal_down
    [:down, 'down'].each { |c| assert_expected_byte(c, 'd') }
  end

  def test_signal_once
    [:once, 'once'].each { |c| assert_expected_byte(c, 'o') }
  end

  def test_signal_pause
    [:pause, 'pause'].each { |c| assert_expected_byte(c, 'p') }
  end

  def test_signal_STOP
    [:STOP, 'STOP'].each { |c| assert_expected_byte(c, 'p') }
  end

  def test_signal_continue
    [:continue, 'continue'].each { |c| assert_expected_byte(c, 'c') }
  end

  def test_signal_CONT         
    [:CONT, 'CONT'].each { |c| assert_expected_byte(c, 'c') }
  end

  def test_signal_hangup       
    [:hangup, 'hangup'].each { |c| assert_expected_byte(c, 'h') }
  end

  def test_signal_HUP          
    [:HUP, 'HUP'].each { |c| assert_expected_byte(c, 'h') }
  end

  def test_signal_alarm        
    [:alarm, 'alarm'].each { |c| assert_expected_byte(c, 'a') }
  end

  def test_signal_ALRM         
    [:ALRM, 'ALRM'].each { |c| assert_expected_byte(c, 'a') }
  end

  def test_signal_interrupt    
    [:interrupt, 'interrupt'].each { |c| assert_expected_byte(c, 'i') }
  end

  def test_signal_INT          
    [:INT, 'INT'].each { |c| assert_expected_byte(c, 'i') }
  end

  def test_signal_terminate    
    [:terminate, 'terminate'].each { |c| assert_expected_byte(c, 't') }
  end

  def test_signal_TERM         
    [:TERM, 'TERM'].each { |c| assert_expected_byte(c, 't') }
  end

  def test_signal_kill         
    [:kill, 'kill'].each { |c| assert_expected_byte(c, 'k') }
  end

  def test_signal_KILL         
    [:KILL, 'KILL'].each { |c| assert_expected_byte(c, 'k') }
  end

  def test_signal_exit         
    [:exit, 'exit'].each { |c| assert_expected_byte(c, 'x') }
  end

  def test_signal_user1        
    [:user1, 'user1'].each { |c| assert_expected_byte(c, '1') }
  end

  def test_signal_USR1         
    [:USR1, 'USR1'].each { |c| assert_expected_byte(c, '1') }
  end

  def test_signal_user2        
    [:user2, 'user2'].each { |c| assert_expected_byte(c, '2') }
  end

  def test_signal_USR2         
    [:USR2, 'USR2'].each { |c| assert_expected_byte(c, '2') }
  end

  private

  def assert_expected_byte(signal, expected)
    @svdir.signal(signal)
    byte = fifo_control.sysread(1)
    assert_equal byte, expected,
                 "read #{byte} after SvDir#signal(#{signal.inspect}), expected #{expected}"
  end

end
