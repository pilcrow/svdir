#!/usr/bin/env ruby

# Author::  Mike Pomraning
# Copyright:: Copyright (c) 2011 Qualys, Inc.
# License:: MIT (see the file LICENSE)
#

require 'sys/sv/statusbytes' # class StatusBytes
require 'sys/sv/util'        # Util::open_write(), open_read()

module Sys # :nodoc
module Sv  # :nodoc:

  # The SvDir class encapsulates service directories, a scheme for
  # reliably controlling daemon processes (services) introduced in Dan
  # Bernstein's +daemontools+ software.
  #
  # Each service is monitored by a _supervisor_, which is responsible
  # for starting, stopping, restarting and generally controlling the
  # service.  Examples of such supervisors include +supervise+ from
  # the +daemontools+ package and +runsv+ from Gerit Pape's compatible
  # +runit+ software.
  #
  # Most SvDir methods will raise <tt>Errno::</tt> exceptions (each
  # a subclass of +SystemCallException+) if the underlying filesystem
  # representation of the service directory is not as expected.  For
  # example, +EACCESS+ or +ENOENT+ may be raised if the _supervisor_'s
  # status directory or state files are missing or unreadable.  Additionally,
  # +ENXIO+ is raised if the _supervisor_ itself isn't running.
  #
 
  class SvDir

    VERSION = '0.2'

    attr_reader :path

    # ...SvDir::Commands = { :alarm => 'a', :ALRM => 'a', :exit => 'x' ... }
    begin
      h = {}
      {
        [:up               ] => 'u',
        [:down             ] => 'd',
        [:once             ] => 'o',
        [:pause,     :STOP ] => 'p',
        [:continue,  :CONT ] => 'c',
        [:hangup,    :HUP  ] => 'h',
        [:alarm,     :ALRM ] => 'a',
        [:interrupt, :INT  ] => 'i',
        [:terminate, :TERM ] => 't',
        [:kill,      :KILL ] => 'k',
        [:exit             ] => 'x',
        [:user1,     :USR1 ] => '1', # runit and some patches to daemontools
        [:user2,     :USR2 ] => '2',
      }.each do | cmds, byte |
        cmds.each { |c| h[c] = byte }
      end
      const_set(:Commands, h)
    end

    # Create a new SvDir corresponding to the service directory +path+.
    def initialize(path)
      @path        = path
    end

    # Send a signal to the service via its _supervisor_.
    #
    # [<tt>:up</tt>] start the service if not running, restarting as necessary.
    # [<tt>:down</tt>] stop the service, issuing a TERM followed by a CONT.  Do not restart it if it stops.
    # [<tt>:once</tt>] start the service if not running, but do not restart it if it stops.
    # [<tt>:pause</tt> or <tt>:STOP</tt>] issue a STOP signal.  See also #paused?.
    # [<tt>:continue</tt> or <tt>:CONT</tt>] issue a CONT signal.  See also #paused?.
    # [<tt>:hangup</tt> or <tt>:HUP</tt>] issue a HUP signal.
    # [<tt>:alarm</tt> or <tt>:ALRM</tt>] issue an ALRM signal.
    # [<tt>:interrupt</tt> or <tt>INT</tt>] issue an INT signal.
    # [<tt>:terminate</tt> or <tt>TERM</tt>] issue a TERM signal.
    # [<tt>:kill</tt> or <tt>KILL</tt>] issue a KILL signal.
    # [<tt>:exit</tt>] tell the _supervisor_ to exit as soon as the service stops.
    # [<tt>:user1</tt> or <tt>:USR1</tt>] issue a USR1 signal.  <i>Not supported by all supervisors</i>
    # [<tt>:user2</tt> or <tt>:USR2</tt>] issue a USR2 signal.  <i>Not supported by all supervisors</i>
    def signal(cmd)
      unless byte = Commands[cmd.to_sym]
        raise ArgumentError.new("unsupported SvDir signal `#{cmd}'")
      end
      Util::open_write(svfn('control')) do |f|
        f.syswrite(byte)
      end
    end

    # Return a SvDir object representing this service's attendant +log+
    # service, otherwise +nil+.
    #
    # Typical SvDir daemons contain a "nested" SvDir responsible for
    # logging the stdout of the base service.  E.g.:
    #
    #   /path/to/services/webserver     # <--- base service
    #   /path/to/services/webserver/log # <--- logger
    # 
    # The +log+ service is supervised and controllable just like the base
    # service.  (Also, the pipe connecting the base service's stdout to
    # the +log+ service's stdin is maintained by a common parent, so that
    # restarting either service won't lose data in the pipe.)
    #
    # Example:
    #
    #   my_serv = Sys::Sv::SvDir.new("path/to/my_serv")
    #   my_serv.signal(:down)
    #   if logger = my_serv.log
    #     logger.signal(:down)
    #   end
    def log
      fn = File.join(@path, 'log')
      return self.class.new(fn) if File.exists? fn
    end

    # Returns +true+ if the service directory's _supervisor_ is running.
    # 
    # To determine whether the service itself is running, see #up?, #down?
    # and #paused?
    def svok?
      Util::open_write(svfn('ok')) { true }
    rescue Errno::ENXIO, Errno::ENOENT
      false # No pipe reader, or no pipe!
    end

    # Returns +true+ if the service is typically running, i.e., if the
    # service directory lacks a <tt>./down</tt> file.
    #
    # Note that this method functions whether or not the service is
    # running, and whether or not a supervisor is running.
    #
    # See also the #want_up? method documentation.
    def normally_up?
      ! normally_down?
    end

    # Returns +true+ if a _supervisor_ will not start the service without
    # explicit instruction to do so.
    #
    # Note that this method functions whether or not the service is
    # running, and whether or not a supervisor is running.
    # 
    # See also the #want_down? method documentation.
    def normally_down?
      File.exists? File.join(@path, 'down')
    end

    # Returns the number of seconds the service has been down,
    # as a float, or +nil+ if the service is in fact running.
    def downtime
      return elapsed() if down?
    end

    # Returns the number of seconds the service has been running,
    # as a float, or +nil+ if the service is not running.
    def uptime
      return elapsed() if up?
    end

    # Return the pid of the service running under this SvDir, or
    # +nil+ if no service is running.
    def pid
      p = statusbytes.pid
      return p == 0 ? nil : p
    end

    # +true+ if the service is not running.
    def down?
      pid.nil?
    end

    # +true+ if the service is running, even if paused.
    def up?
      !down?
    end

    # Returns +true+ if the service is paused, that is, has received
    # a SIGSTOP.
    def paused?
      statusbytes.pauseflag != 0
    end

    # Returns +true+ if the service's supervisor has been instructed to
    # bring the service down.
    def want_down?
      statusbytes.wantflag == 'd'
    end

    # Returns +true+ if the service's supervisor has been instructed to
    # bring the service up.
    def want_up?
      statusbytes.wantflag == 'u'
    end

    private

    def elapsed
      statusbytes.elapsed
    end

    def svfn(basename)
      File.join(@path, 'supervise', basename)
    end

    # Instantiate our one-time, delegate helper class
    def statusbytes
      # We _want_ to pass Errno back to caller, which is why we don't
      # simply call #svok?() here.
      Util::open_write(svfn('ok')) {true}

      buf = Util::open_read(svfn('status')) do |f|
              begin
                f.sysread( StatusBytes::BUFLEN )
              rescue ::EOFError
                ""
              end
            end
      StatusBytes.new(buf)
    end

  end

end #-- module Sv
end #-- module Sys
