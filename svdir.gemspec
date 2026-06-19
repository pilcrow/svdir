Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.author       = "Mike Pomraning"
  s.summary      = "An interface to service directories ala supervise/runsv"
  s.name         = 'svdir'
  s.version      = '0.2.1'
  s.require_path = 'lib'
  s.license      = 'MIT'
  s.description  = <<~eodesc
    The svdir package controls service directories, a scheme for reliably
    controlling daemon processes as implemented in Dan Bernstein's daemontools
    software ("supervise") or Gerit Pape's runit software ("runsv").
  eodesc

  s.files       = Dir['Rakefile', 'CHANGELOG', 'LICENSE', 'README',
                       'lib/**/*.rb', 'test/**/*', 'example/*']
  s.test_files  = Dir['test/ts_*.rb']
end
