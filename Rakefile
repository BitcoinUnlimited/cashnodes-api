require_relative './cashnodes_api'
require 'rake'
require 'rake/testtask'
require 'byebug'
require 'bundler/audit/task'

Rake::TestTask.new do |t|
  t.pattern = "tests/**/test_*.rb"
end

Bundler::Audit::Task.new
