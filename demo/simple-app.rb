require 'sinatra'

get '/hi' do
  sleep 2
  "Hello World!"
end
