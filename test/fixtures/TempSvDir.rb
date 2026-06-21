# frozen_string_literal: true

# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2026 Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# License:: MIT (see the file LICENSE)

require 'tmpdir'       # Dir.tmpdir
require 'fileutils'    # FileUtils.rm_rf
require 'sys/sv/svdir'

module Fixtures
  module TempSvDir
    # Test::Unit::TestCase mixin to create one-off service directories

    # Make a temp sv-style dir with supervise/ subdir and two FIFOs
    def setup # rubocop:disable Metrics/MethodLength
      i = 0

      # make a temporary dir
      begin
        @svdirname = File.join(Dir.tmpdir, "TempSvDir.#{$$}.#{i}") # rubocop:disable Style/SpecialGlobalVars
        i += 1
        Dir.mkdir(@svdirname)
      rescue Errno::EEXIST
        retry if i < 100
        raise "Unable to create a mock svc dir.  Check #{Dir.tmpdir}"
      end

      Dir.mkdir File.join(@svdirname, 'supervise')

      # Make and hold open our FIFOs
      @fifos = {}
      %w[control ok].each do |fn|
        @fifos[fn.to_sym] = openfifo(File.join(@svdirname, 'supervise', fn))
      end

      @svdir = Sys::Sv::SvDir.new(@svdirname)
      super
    end

    def fifo_control
      @fifos[:control]
    end

    def fifo_ok
      @fifos[:ok]
    end

    def teardown
      @fifos.each_value do |f|
        f.close
      rescue StandardError
        nil
      end
      FileUtils.rm_rf(@svdirname)
      super
    end

    private

    def openfifo(fn)
      system "mkfifo #{Regexp.quote(fn)}"
      File.open(fn, File::NONBLOCK | File::RDONLY)
    end
  end
end # -- module Fixtures
