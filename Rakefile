require 'rubygems'
require 'rake'
require 'rake/testtask'

desc "Run all tests for this project."
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test