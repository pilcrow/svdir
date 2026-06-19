require 'rubygems/package_task'
require 'rdoc/task'
require 'rake/testtask'

spec = Gem::Specification.load('svdir.gemspec')

Gem::PackageTask.new(spec) do |pkg|
  pkg.package_dir = 'pkg'
  pkg.need_tar = true
end

desc "Generate rdoc"
RDoc::Task.new("rdoc") do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.title    = "svdir"
  rdoc.options << "--inline-source" << "--line-numbers"
  rdoc.options << '--main' << 'README'
  rdoc.rdoc_files.include('lib/**/*.rb',
                          'CHANGELOG',
                          'README',
                          'LICENSE')
end

desc "Run included tests"
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = Dir['test/ts_*.rb']
  t.libs << "lib"
end

desc "Run test coverage (rcov)"
begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.test_files = Dir['test/ts_*.rb']
    t.libs << "test" << "lib"
    t.rcov_opts << '--exclude /gems/,/Library/,/usr/,spec,lib/tasks'
  end
rescue LoadError
  task :rcov do
    puts "Error - you seem to be missing 'rcov'"
    exit 1
  end
end
