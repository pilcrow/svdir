#!/usr/bin/env ruby

# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# License:: MIT (see the file LICENSE)

require 'test/unit'

class Test::Unit::TestCase
  # Load the appropriate Fixtures::Blah
  def self.include_fixtures(sym, *optional)
    raise RuntimeError.new("Must subclass Test::Unit::TestCase") \
      if self == Test::Unit::TestCase

    for s in [sym, *optional]
      load "fixtures/#{sym}.rb"
      self.__send__(:include, Module.const_get(:Fixtures).const_get(sym))
    end

  end

  def self.include_fixture(sym)
    include_fixtures(sym)
  end
                               
  def assert_elapsed_time(elapsed)
    assert_kind_of(::Float, elapsed, "elapsed time measurement was wrong type")
    assert(elapsed > 0.0, "elapsed time measurement was not > 0")
  end
end
