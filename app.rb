require 'sinatra/base'
require 'sinatra/cross_origin'
require 'json'

require './records'

class MoneyApp < Sinatra::Base
  register Sinatra::CrossOrigin

  def initialize
    super
    @record = Record.new('moneyfile')
  end

  configure do
    enable :cross_origin
  end
  
  before do
    content_type 'application/json'
  end

  get '/' do
    content_type 'text/html'
    send_file File.join(settings.public_folder, 'index.html')
  end

  options "*" do
    response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"

    response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"

    200
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
