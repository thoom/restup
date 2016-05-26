require 'sinatra'

get '/hi' do
  #   sleep 2
  'Hello World!'
end

post '/send' do
  'received: ' + request.body.read
end
