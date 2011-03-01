#
# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# License:: MIT (see the file LICENSE)
# 

module Sys # :nodoc:
module Sv  # :nodoc:

  # The StatusBytes class interprets state files maintained by a SvDir's
  # _monitor_ process.  It should normally not be instantiated directly.
  class StatusBytes # :nodoc:
    BUFLEN    = 18                  # TODO - grok runit extended info (20 bytes)
    TAI_EPOCH = 4611686018427387914 # time_t 0 on the TAI scale

    attr_reader :pid, :pauseflag, :wantflag

    def initialize(bytes) # :nodoc:
      if bytes.size < BUFLEN
        raise ::Errno::EPROTO.new("corrupt status buffer")
      end

      @bytes = bytes
      @pid, @pauseflag, @wantflag = @bytes.unpack('x12 V c a')
      @epoch = nil # computed if needed
    end

    # Number of seconds since service was most recently started or
    # stopped.
    def elapsed
      ::Time.now.to_f - epoch()
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
        @epoch += nano/10e9
      end

      @epoch
    end
  end

end #-- module Sv
end #-- module Sys
