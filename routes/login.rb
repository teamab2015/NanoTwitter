module Sinatra
  module NanoTwitter
    module Routing
      module Login

        def self.registered(app)
            #display register page
            app.get '/user/register' do
                logged_in_user_id = Authentication.get_logged_in_user_id(session)
                if logged_in_user_id.nil? then
                    erb :register
                else
                    redirect to("/user/#{logged_in_user_id}")
                end
            end

            app.post '/user/register' do
                begin
                    User.register(name: params[:name],
                                  email: params[:email],
                                  password: params[:password],
                                  username: params[:username])
                    redirect to("/")
                rescue => error
                    @error_message = error.message
                    erb :register
                end
            end

            #display the login page, after logging in redirect to /user/:id
            app.get '/login' do
                redirect to("/")
            end

            app.post '/login' do
                email = params[:email]
                password = params[:password]
                user = User.find_by(email: email, password: password)
                if (user == nil) then
                    redirect to('/')
                else
                    session[:user_id] = user[:id]
                    redirect to("/user/#{user[:id]}")
                end
            end

            #log in the user with user_id, may accept requests with password parameter to log in
            app.get '/login/:id' do
                id = params['id'].to_i
                session[:user_id] = id
                redirect to("/user/#{id}")
            end

            #log out the current user, after logging out redirect to /
            app.get '/logout' do
                session[:user_id] = nil
                redirect to("/")
            end
        end

      end
    end
  end
end
