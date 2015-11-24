require './app'
require 'sinatra/activerecord/rake'
require 'resque/tasks'

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end
