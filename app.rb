require 'sinatra/base'

require './records'

class MoneyApp < Sinatra::Base
  get '/' do
    'Hello, money app!'
  end
end
