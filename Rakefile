require 'rubygems'
require 'bundler'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "subtrigger"
    gem.summary = %Q{Create post-commit triggers for Subversion commit messages}
    gem.description = %Q{This gem allows you to create simple Ruby triggers for Subversion commit messages, responding to keywords in your log messages to send e-mails, deploy sites or do whatever you need.}
    gem.email = "arjan@arjanvandergaag.nl"
    gem.homepage = "http://github.com/avdgaag/subtrigger"
    gem.authors = ["Arjan van der Gaag"]
    gem.add_bundler_dependencies
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.options = [
      '--files', 'LICENSE',
      '--files', 'HISTORY.md',
      '--title', 'Subtrigger API documentation'
    ]
  end
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
