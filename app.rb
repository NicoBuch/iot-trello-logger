require 'dotenv'
Dotenv.load

require 'sinatra'
require 'trello'


Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_MEMBER_TOKEN']
end


get '/boards' do
  halt 400 unless params[:user].present?
  member = Trello::Member.find(params[:user])
  member.boards.map { |b| { id: b.id, name: b.name } }.to_json
end

get '/cards' do
  halt 400 unless params[:board_id].present? && params[:user].present?
  board = Trello::Board.find(params[:board_id])
  member = Trello::Member.find(params[:user])
  cards = board.cards.select { |card| card.member_ids.include?(member.id) }
  member.cards.map { |c| { id: c.id, name: c.name } }.to_json
end

get '/log' do
  halt 400 unless params[:card_id].present? && params[:seconds].present?
  card = Trello::Card.find(params[:card_id])
  # halt 403 unless card.member_ids.include?(ENV['USER_ID'])
  hours = seconds_to_hours(params[:seconds].to_i)
  card.add_comment("plus! #{hours}/0")
  'ok'
end


def seconds_to_hours(seconds)
  (seconds / 3600.0).round(2)
end
