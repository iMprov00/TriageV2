class ApplicationController < Sinatra::Base
  configure do
    set :views, 'app/views'
    set :public_folder, 'app/public'
    set :method_override, true
  end

  get '/' do
    erb :index
  end

  not_found do
    status 404
    erb :not_found
  end
end