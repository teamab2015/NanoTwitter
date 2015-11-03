rake db:drop RACK_ENV=test
rake db:create RACK_ENV=test
rake db:schema:load RACK_ENV=test
rake test
