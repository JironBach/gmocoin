require "faye/websocket"
require "eventmachine"
require 'json'

EM.run {
  ws = Faye::WebSocket::Client.new("wss://api.coin.z.com/ws/public/v1")

  ws.on :open do |event|
    message = {
      :command => "subscribe",
      :channel => "ticker",
      :symbol => 'XRP'
    }
    ws.send(message.to_json)
  end

  ws.on :message do |event|
    puts event.data
  end
}
