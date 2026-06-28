# frozen_string_literal: true

# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2026 Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# License:: MIT (see the file LICENSE)

require 'sys/sv/svdir'

module Fixtures
  module PrefabSvDir
    # Test::Unit::TestCase helper to recognize "static" supervisory
    # directories.
    #
    # If the including class defines +PREFAB_FIXTURE+, use that as
    # the fixture subdirectory name under test/services/.  Otherwise
    # derive it from the class name (existing convention).
    def setup
      dirname = if self.class.const_defined?(:PREFAB_FIXTURE)
                  self.class::PREFAB_FIXTURE
                else
                  self.class.name.gsub(/^TC_/, '').tr('_', '-')
                end

      dirname = File.join(File.dirname(__FILE__), '..', 'services', dirname)

      raise "Expected static testing dir #{dirname} not found" unless File.directory? dirname

      @svdir = Sys::Sv::SvDir.new dirname
      super
    end
  end
end # -- module Fixtures
