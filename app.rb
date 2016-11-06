require 'sinatra/base'

require './records'

class MoneyApp < Sinatra::Base
  get '/' do
    bruce = Person.new('Bruce')
    bruce.name
  end
end
