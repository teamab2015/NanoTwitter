configure :production do
  puts "[production environment]"
  db = URI.parse(ENV['HEROKU_POSTGRESQL_COPPER_URL'] || ENV['DATABASE_URL'] || 'postgres://localhost/mydb')

  ActiveRecord::Base.establish_connection(
      :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :username => db.user,
      :password => db.password,
      :database => db.path[1..-1],
      :encoding => 'utf8'
  )
end

configure :development do
  puts "[develoment Environment]"
end

configure :test do
  puts "[test Environment]"
end
