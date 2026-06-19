# svdir Code Review

Reviewed by:   opencode (big-pickle model)
Review date:   2026-06-19
Repository:    svdir (Qualys, Inc., 2008–2011)
Branch:        review

## Overview

`svdir` is a small Ruby library (~300 lines across 3 source files) that
provides a programmatic interface to daemontools/runit service directories.
It reads binary `supervise/status` files and writes single-byte commands to
`supervise/control` FIFOs without shelling out.  The distribution also
includes:

- An example CLI tool (`example/svctl`)
- Unit tests using `Test::Unit` with static binary fixture data
- A Rakefile for gem packaging and rdoc

## Bugs

### Bug 1: TAI64N fractional-seconds divisor off by 10×

File: `lib/sys/sv/statusbytes.rb`, line 45

```ruby
@epoch += nano/10e9
```

`10e9` evaluates to `1.0e10` (10,000,000,000), but `nano` is a nanosecond
value in `[0, 999999999]`.  The correct divisor is `1e9` (1,000,000,000),
i.e. `1e9` or `10**9`.  As written, fractional seconds are under-reported
by a factor of 10 (e.g. 500ms reads as 50ms).

Impact: `#uptime` and `#downtime` return slightly incorrect values
(off by up to ~0.9 seconds per elapsed interval).  For long-running
services the error is negligible, but it's still wrong.

### Bug 2: `include_fixtures` ignores loop variable

File: `test/testbase.rb`, lines 15–17

```ruby
for s in [sym, *optional]
  load "fixtures/#{sym}.rb"
  self.__send__(:include, Module.const_get(:Fixtures).const_get(sym))
end
```

Both lines use `sym` (the first argument) instead of `s` (the loop
variable).  This means passing multiple fixture names would load and
include the first fixture multiple times, not the intended ones.

Never triggered in practice — all call sites pass a single fixture.
Should still be fixed.

## Deprecations & Compatibility (Ruby ≥2.x)

These produce warnings on modern Ruby but don't break functionality:

| Location | Code | Replacement |
|---|---|---|
| `svdir.rb:113`, `svdir.rb:145` | `File.exists?` | `File.exist?` |
| `svdir.rb:113` | `File.exists?` (for `log/` dir) | `File.directory?` would be more precise |
| `test/fixtures/TempSvDir.rb:23` | `Dir::mkdir` | `Dir.mkdir` |
| `test/fixtures/TempSvDir.rb:21` | `Dir::tmpdir` | `Dir.tmpdir` |
| `test/fixtures/TempSvDir.rb:25` | `Dir::tmpdir` | `Dir.tmpdir` |

## Rakefile — Broken on Modern Rake

`Rakefile` uses two deprecated/removed require paths:

- `require 'rake/gempackagetask'` — removed in Rake ≥12.  Use
  `require 'rake/gempackagetask'` or switch to `Gem::PackageTask`
  from rubygems itself.
- `require 'rake/rdoctask'` — removed.  Use `require 'sdoc'` or
  `require 'rdoc/task'`.

Also calls `Gem::Specification#has_rdoc=` which is a no-op on modern
rubygems.

Fix: rewrite the Rakefile or replace with a `gemspec`.

## Style Observations

### Good

- Clean `Sys::Sv` namespace, clear public/private separation.
- `syswrite` correctly used for FIFO writes (not buffered `write`).
- Binary parsing via `Array#unpack` is correct for the struct layout.
- Proper `ensure` block for file handle cleanup in `Util.open_nonblock`.
- Thoughtful exception design — raises `Errno::EPROTO` for corrupt
  status, `Errno::ENXIO` for missing supervisor.
- Tests cover all state permutations (up/down/paused/want/normally)
  using pre-recorded binary fixtures — clever way to avoid needing a
  live `supervise` process.
- Signal mapping table is concise and complete.

### Could Improve

- The `Commands` hash is built dynamically via `begin`/`const_set`
  instead of a frozen literal.  A hash literal with `freeze` would be
  clearer.
- No constants are frozen — adding `# freeze` to `Commands` and
  `StatusBytes::BUFLEN`/`TAI_EPOCH` is free rigor.
- `statusbytes` private method opens `supervise/ok` (a FIFO) just as a
  liveness probe on every status read.  Combined with the fact that
  `#pid`, `#up?`, `#down?`, `#paused?`, `#want_up?`, `#want_down?`,
  `#uptime`, `#downtime` all call `statusbytes`, this means a live
  FIFO open+close per call.  A small cache or a batch-read method
  would be more efficient for polling use cases.
- Mix of `for` and `.each` iteration styles.
- `#log` uses `File.exists?` rather than `File.directory?`, so it
  would match a regular file named `log` too.

## Architecture Notes

The library is a thin, correct mapping over the daemontools/runit
filesystem protocol.  No over-engineering.  The example `svctl` script
demonstrates a typical workflow.

The main efficiency consideration: every status query re-reads the
binary `supervise/status` file from disk + probes the `supervise/ok`
FIFO.  For a one-shot CLI tool this is fine.  For a long-running
monitoring loop you'd want to cache the `StatusBytes` object briefly.

## Recommendations

1. Fix the `10e9` → `1e9` typo (statusbytes.rb:45).
2. Fix the `sym` → `s` loop variable (testbase.rb:15–17).
3. Fix `File.exists?` → `File.exist?` and `File.exists?` → `File.directory?`
   for the `log/` check (svdir.rb:113, 145).
4. Fix `Dir::mkdir` → `Dir.mkdir`, `Dir::tmpdir` → `Dir.tmpdir`
   (TempSvDir.rb).
5. Update the Rakefile for modern Rake / rubygems.
6. Optionally freeze constants (`Commands`, `BUFLEN`, `TAI_EPOCH`).
7. Optionally batch status reads or add a small cache if polling
   performance matters.
8. Verify tests pass on a modern Ruby (≥2.7) — preferably in Docker
   to avoid polluting the host system.
