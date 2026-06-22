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
  #
  # DJB buflen is 18 bytes, runit buflen is 20.  The state file:
  #
  # off  sz  what      encoding      description
  # ---  --  -------   ------------- ------------
  #  0    8  tai sec   big-endian    TAI-64 timestamp (struct tai)
  #  8    4  nano      big-endian    nanoseconds (struct taia nano field)
  # 12    4  pid       little-endian process ID
  # 16    1  paused    0/1           1 if process is SIGSTOP'd
  # 17    1  want     'u'/'d'        'u' = want up, 'd' = want down
  # 18    1  got TERM  0/1           (runit extension) 1 if SIGTERM has been sent
  # 19    1  state     0/1/2         (runit extension) 0 = down, 1 = running, 2 = finish

  class StatusBytes # :nodoc:
    BUFLEN    = 20                        # 20 for runit, 18 for daemontools
    TAI_EPOCH = 4_611_686_018_427_387_914 # time_t 0 on the TAI scale

    attr_reader :bytes, :pid, :pauseflag, :wantflag, :termflag, :runstate

    def initialize(bytes) # :nodoc:
      raise(::Errno::EPROTO, 'corrupt status buffer') unless [18, 20].include?(bytes.size)

      @bytes = bytes
      @pid, @pauseflag, @wantflag,
        @termflag, @runstate = @bytes.unpack('x12 V c a c c')
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
