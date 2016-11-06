require 'sinatra/base'
require 'json'

require './records'

class MoneyApp < Sinatra::Base
  def initialize
    super
    @record = Record.new('moneyfile')
  end

  before do
    content_type 'application/json'
  end

  get '/people' do
    {
      people: @record.people
    }.to_json
  end

  get '/active' do
    @record.active_entries.to_json
  end

  get '/transactions' do
    {
      transactions: @record.transactions
    }.to_json
  end

  post '/transactions' do
    payload = JSON.parse(request.body.read)

    unless ['from', 'to', 'amount'].map { |k| payload.key?(k) }.all?
      status 400
      return "Missing request keys"
    end

    t = @record.add_transaction(
      payload['from'], 
      payload['to'], 
      payload['amount'], 
      payload['comment']
    )

    unless t
      status 400
      return "Invalid transaction"
    end

    status 200
  end

  post '/save' do
    @record.write!
  end
end
