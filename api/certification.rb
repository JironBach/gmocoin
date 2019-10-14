#! /usr/bin/env ruby
# coding: utf-8

require 'net/http'
require 'json'
require 'openssl'
require 'base64'
require 'date'

apiKey    = 'sGVW3VpGDC21I1vjFNHEa8lEaoKfLP/B'
secretKey = '71xoPNxHQ3DxkR/5IfvrI0EZrFdk2Sev7jaOi0pKnhhliWC812X+c2P0DoOtAv4s'

timestamp = DateTime.now.strftime('%Q')
method    = 'POST'
endPoint  = 'https://api.coin.z.com/public'
path      = '/v1/status'
reqBody   = {}

text = timestamp + method + path + reqBody.to_json
sign = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, secretKey, text)

uri = URI.parse(endPoint + path)
req = Net::HTTP::Post.new(uri.to_s)

req['API-KEY'] = apiKey
req['API-TIMESTAMP'] = timestamp
req['API-SIGN'] = sign

req.body = reqBody.to_json

response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') {|http|
  http.request(req)
}
puts JSON.pretty_generate(JSON.parse(response.body), :indent=>'  ')

