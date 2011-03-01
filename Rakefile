require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'

FILES = FileList['Rakefile', 'CHANGELOG', 'LICENSE', 'README',
                 'lib/**/*.rb', 'test/**/*', 'example/*'].to_a
TESTS = FileList['test/ts_*.rb']

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.author = "Mike Pomraning"
  s.summary = "An interface to service directories ala supervise/runsv"
  s.name = 'svdir'
  s.version = '0.2'
  s.require_path = 'lib'
  s.description = <<eodesc
The svdir package controls service directories, a scheme for reliably
controlling daemon processes as implemented in Dan Bernstein's daemontools
software ("supervise") or Gerit Pape's runit software ("runsv").
eodesc
  s.files = FILES
  s.test_files = TESTS
  s.has_rdoc = true
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.package_dir = 'pkg'
    pkg.need_tar = true
end

desc "Generate rdoc"
Rake::RDocTask.new("rdoc") do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.title    = "svdir"
  # Show source inline with line numbers
  rdoc.options << "--inline-source" << "--line-numbers"
  # Make the readme file the start page for the generated html
  rdoc.options << '--main' << 'README'
  rdoc.rdoc_files.include('lib/**/*.rb',
                          'CHANGELOG',
                          'README',
                          'LICENSE')
end

desc "Run included tests"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = TESTS
  t.libs << "lib"
end

desc "Run test coverage (rcov)"
begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.test_files = TESTS
    t.libs << "test" << "lib"
    t.rcov_opts << '--exclude /gems/,/Library/,/usr/,spec,lib/tasks'
  end
rescue LoadError
  task :rcov do
    puts "Error - you seem to be missing 'rcov'"
    exit 1
  end
end
