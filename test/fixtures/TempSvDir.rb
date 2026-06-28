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
    # Default 18-byte daemontools status: TAI64 ~2023-11, nano=500ms,
    # pid=12345, not paused, want='u' (up).  Individual test classes
    # may define their own STATUS_BYTES to override this default.
    # TAI64 = unix_epoch + TAI_EPOCH; hi=0x40000000, lo=0x6562E70A
    STATUS_BYTES = [0x40000000, 0x6562E70A, 500_000_000,
                    12_345, 0, 'u'].pack('NNNVca').freeze

    # Returns the path to the superivse/status file
    def status_path
      File.join(@svdirname, 'supervise', 'status')
    end

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

      # Write a static status file so Cached (and statusbytes) have
      # something to read.  Override STATUS_BYTES in the test class
      # or overwrite status_path in setup after super.
      File.write(status_path, self.class::STATUS_BYTES)

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
      File.mkfifo(fn)
      File.open(fn, File::NONBLOCK | File::RDONLY)
    end
  end
end # -- module Fixtures
