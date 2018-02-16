require_relative './cashnodes_api'
require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "tests/**/test_*.rb"
end

task default: :test
