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
- Mix of `for` and `.each` iteration styles.
- `#log` uses `File.exists?` rather than `File.directory?`, so it
  would match a regular file named `log` too.

## Architecture Notes

The library is a thin, correct mapping over the daemontools/runit
filesystem protocol.  No over-engineering.  The example `svctl` script
demonstrates a typical workflow.

Each method call reads the `supervise/status` file from scratch, which
is by design — the interface provides point-in-time snapshots of a
realtime daemon.  There is no locking convention in the DJB/runit
ecosystem, and caching could return stale data.  A snapshot-oriented
subclass or user-configurable overlay could be added if needed, but
there's no inherent advantage for the common use case.

## Target Versions

The codebase should be updated to support **Ruby 3.3, 3.4, and 4.0**
(the currently maintained Ruby branches as of June 2026).  Ruby 4.0 was
released 2025-12-25 and is at 4.0.5; Ruby 3.4 at 3.4.9; Ruby 3.3 at
3.3.11.

Key compatibility facts discovered during review:

- **Ruby 3.2 removed `File.exists?`** (and `Dir.exists?`), deprecated
  since Ruby 2.1.  The code uses `File.exists?` in two places
  (svdir.rb:113, 145) — this is the sole blocker across 3.3/3.4/4.0.
  Ruby 3.1 still has it (with a deprecation warning).
- **Ruby 4.0** introduces no further breaking changes relevant to this
  codebase beyond what 3.2 enforces.  The library uses only core/stdlib.
- The **Rakefile** relies on `rake/gempackagetask` and `rake/rdoctask`,
  which were removed in Rake ≥12 (shipped with Ruby ≥3.x).  Needs a
  rewrite regardless of Ruby version.

## Recommendations

All changes should target Ruby 3.3, 3.4, and 4.0.

### Required (blocking)

1. **Fix `File.exists?` → `File.exist?`** (svdir.rb:113, 145).
   Also change the `log/` check from `File.exists?` to `File.directory?`
   for correctness (svdir.rb:113).
2. **Fix the `10e9` → `1e9` typo** (statusbytes.rb:45).
3. **Fix the `sym` → `s` loop variable** in `include_fixtures`
   (testbase.rb:15–17).
4. **Fix `Dir::mkdir` → `Dir.mkdir`, `Dir::tmpdir` → `Dir.tmpdir`**
   (TempSvDir.rb).
5. **Fix duplicate test name** `test_normally_down?` in ts_nosupervisor.rb.
   Line 75 tests `#log` and should be named `test_log`.
6. **Update Rakefile** — replace `rake/gempackagetask` and `rake/rdoctask`
   with their modern equivalents, or replace with a `gemspec`.

### Optional (polish)

7. Freeze constants (`Commands`, `BUFLEN`, `TAI_EPOCH`).

## Test Results — Docker (Ruby 3.3, 3.4)

Tests were run identically on `ruby:3.3` (3.3.11) and `ruby:3.4` (3.4.9).
Both produced the same result.

### Result: 82.95% passed

```
176 tests, 185 assertions, 2 failures, 28 errors
```

### Root cause of all failures

**`File.exists?` removed in Ruby 3.2.** Every single error/failure traces to:

```
NoMethodError: undefined method 'exists?' for class File
```

Stack: `svdir.rb:145` → `normally_down?` → called by `normally_up?` and
directly by tests.  `File.exists?` was deprecated since Ruby 2.1, produced
warnings in 3.0–3.1, and was deleted in 3.2.  Ruby 3.3, 3.4, and 4.0 all
lack it.

### Breakdown

| Test file | Tests | Errors | Failures | Cause |
|---|---|---|---|---|
| `ts_svstat.rb` | 130 | 24 | 0 | `File.exists?` in `normally_down?` |
| `ts_corrupt.rb` | 24 | 4 | 0 | `File.exists?` in `normally_down?` |
| `ts_nosupervisor.rb` | 14 | 0 | 2 | `File.exists?` in `normally_down?`/`log` |
| `ts_signal.rb` | 8 | 0 | 0 | — |

The signal tests (ts_signal.rb) passed cleanly — they exercise FIFO I/O
via TempSvDir, not the `down` file check.

### Bonus issue found at runtime

`ts_nosupervisor.rb` defines `test_normally_down?` **twice** (lines 68 and
75).  The second definition (intended to test `#log`) silently overwrites
the first (which tested `#normally_down?`).  test-unit emits a notification:

```
Notification: <TestSvcNoSupervisor#test_normally_down?> was redefined
```

Line 75's test name should be `test_log` instead.  Only one `normally_down?`
test in the no-supervisor case actually ran.
