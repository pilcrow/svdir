#
# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# Copyright:: Copyright (c) 2016 Mike Pomraning
# License:: MIT (see the file LICENSE)
#

module Sys # :nodoc:
module Sv  # :nodoc:

  module Util #:nodoc:
    def self.open_read(fn, &p)
      open_nonblock(fn, File::RDONLY, nil, p)
    end

    def self.open_write(fn, &p)
      open_nonblock(fn, File::WRONLY, nil, p)
    end

    def self.open_excl(fn, mode: nil, &p)
      oflags = File::WRONLY|File::CREAT|File::EXCL
      open_nonblock(fn, oflags, mode, p)
    end

    private
    def self.open_nonblock(fn, oflags, mode, p)
      args = [ fn, oflags|File::NONBLOCK ]
      args << mode if mode
      return File.open(*args) if p.nil?

      begin
        f = File.open(*args)
        return p.call(f)
      ensure
        f.close if f
      end
    end
  end #-- module Util

end #-- module Sv
end #-- module Sys
