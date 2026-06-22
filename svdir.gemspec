require_relative 'lib/sys/sv/svdir'

Gem::Specification.new do |s|
  s.name         = 'svdir'
  s.version      = Sys::Sv::SvDir::VERSION
  s.required_ruby_version = '>= 2.6.0'
  s.summary      = "An interface to service directories ala supervise/runsv"
  s.platform     = Gem::Platform::RUBY
  s.author       = "Mike Pomraning"
  s.require_path = 'lib'
  s.license      = 'MIT'
  s.description  = <<~eodesc
    The svdir package controls service directories, a scheme for reliably
    controlling daemon processes as implemented in Dan Bernstein's daemontools
    software ("supervise") or Gerit Pape's runit software ("runsv").
  eodesc

  s.homepage    = 'https://github.com/pilcrow/svdir'
  s.metadata    = { 'source_code_uri' => 'https://github.com/pilcrow/svdir' }

  s.files       = Dir['Rakefile', 'CHANGELOG', 'LICENSE', 'README',
                       'lib/**/*.rb', 'test/**/*', 'example/*']
  s.test_files  = Dir['test/ts_*.rb']
end
