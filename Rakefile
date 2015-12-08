require './app'
require 'sinatra/activerecord/rake'
require 'resque/tasks'

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
end

task "resque:pool:setup" do
  # close any sockets or files in pool manager
  ActiveRecord::Base.connection.disconnect!
  Resque::Pool.after_prefork do
    ActiveRecord::Base.establish_connection
  end
end
