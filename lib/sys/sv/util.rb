#
# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# License:: MIT (see the file LICENSE)
#

require 'fcntl' # O_RDONLY | O_NONBLOCK

module Sys # :nodoc:
module Sv  # :nodoc:

  module Util #:nodoc:
    def self.open_read(fn, &p)
      open_nonblock(fn, Fcntl::O_RDONLY, p)
    end

    def self.open_write(fn, &p)
      open_nonblock(fn, Fcntl::O_WRONLY, p)
    end

    private
    def self.open_nonblock(fn, mode, p)
      mode |= Fcntl::O_NONBLOCK
      return File.open(fn, mode) if p.nil?

      begin
        f = File.open(fn, mode)
        return p.call(f)
      ensure
        f.close if f
      end
    end
  end #-- module Util

end #-- module Sv
end #-- module Sys
