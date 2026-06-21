# frozen_string_literal: true

# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# Copyright:: Copyright (c) 2026 Mike Pomraning
# License:: MIT (see the file LICENSE)
#

module Sys # :nodoc:
module Sv  # :nodoc: # rubocop:disable Layout::IndentationWidth
  # The StatusBytes class interprets state files maintained by a SvDir's
  # _monitor_ process.  It should normally not be instantiated directly.
  class StatusBytes # :nodoc:
    BUFLEN    = 18                        # TODO: grok runit extended info (20 bytes)
    TAI_EPOCH = 4_611_686_018_427_387_914 # time_t 0 on the TAI scale

    attr_reader :pid, :pauseflag, :wantflag

    def initialize(bytes) # :nodoc:
      raise(::Errno::EPROTO, 'corrupt status buffer') if bytes.size < BUFLEN

      @bytes = bytes
      @pid, @pauseflag, @wantflag = @bytes.unpack('x12 V c a')
      @epoch = nil # computed if needed
    end

    # Number of seconds since service was most recently started or
    # stopped.
    def elapsed
      ::Time.now.to_f - epoch
    end

    # Returns the number of seconds since the UNIX epoch since the
    # service was most recently started or stopped.
    def epoch
      return @epoch if @epoch

      # assemble UNIX-scale seconds from TAI64N label
      hi32, lo32, nano = @bytes.unpack('N N N')
      @epoch = (hi32 << 32) + lo32 - TAI_EPOCH
      if @epoch <= 0
        @epoch = 0.0
      else
        @epoch += nano / 1e9
      end

      @epoch
    end
  end
end #-- module Sv
end #-- module Sys
