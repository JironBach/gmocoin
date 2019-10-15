require 'net/http'
require 'json'
require 'openssl'
require 'base64'
require 'date'

apiKey    = ENV['API_KEY']
secretKey = ENV['SECRET_KEY']

timestamp = DateTime.now.strftime('%Q')
method    = 'GET'
endPoint  = 'https://api.coin.z.com/private'
path      = '/v1/orders'
parameters = {
  :orderId => 123456789
}

text = timestamp + method + path
sign = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, secretKey, text)

uri = URI.parse(endPoint + path)
uri.query = URI.encode_www_form(parameters)
req = Net::HTTP::Get.new(uri.to_s)

req['API-KEY'] = apiKey
req['API-TIMESTAMP'] = timestamp
req['API-SIGN'] = sign

response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') {|http|
  http.request(req)
}
puts JSON.pretty_generate(JSON.parse(response.body), :indent=>'  ')

