#!/usr/bin/env ruby

# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# License:: MIT (see the file LICENSE)

require 'sys/sv/svdir'

module Fixtures
  module PrefabSvDir
  # Test::Unit::TestCase helper to recognize "static" supervisory
  # directories.
    def setup
      dirname = self.class.name.gsub(/^TC_/, '').tr('_', '-')
      dirname = File.join(File.dirname(__FILE__), '..', 'services', dirname)

      raise RuntimeError.new("Expected static testing dir #{dirname} not found") unless File.directory? dirname
      @svdir = Sys::Sv::SvDir.new dirname
      super
    end
  end
end # -- module Fixtures
