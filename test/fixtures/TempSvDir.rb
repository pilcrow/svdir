#!/usr/bin/env ruby

# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# License:: MIT (see the file LICENSE)

require 'tmpdir'       # Dir.tmpdir
require 'fileutils'    # FileUtils.rm_rf
require 'sys/sv/svdir'

module Fixtures
  module TempSvDir
    # Test::Unit::TestCase mixin to create one-off service directories

    # Make a temp sv-style dir with supervise/ subdir and two FIFOs
    def setup
      i = 0

      # make a temporary dir
      begin
        @svdirname = File.join(Dir::tmpdir, "TempSvDir.#{$$}.#{i}")
        i += 1
        Dir::mkdir(@svdirname)
      rescue Errno::EEXIST
        retry if i < 100
        raise RuntimeError.new("Unable to create a mock svc dir.  Check #{Dir::tmpdir}")
      end

      Dir::mkdir File.join(@svdirname, "supervise")

      # Make and hold open our FIFOs
      @fifos = {}
      for fn in %w(control ok)
        @fifos[ fn.to_sym ] = openfifo(File.join(@svdirname, "supervise", fn))
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
      @fifos.each_value {|f| f.close rescue nil}
      FileUtils.rm_rf( @svdirname )
      super
    end

    private
    def openfifo(fn)
      system "mkfifo #{Regexp.quote(fn)}"
      File.open(fn, Fcntl::O_NONBLOCK|Fcntl::O_RDONLY)
    end
  end

end # -- module Fixtures
