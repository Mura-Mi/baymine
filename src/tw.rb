require 'twitter'
require 'dotenv'

Dotenv.load

CONSUMER_KEY = ENV['CONSUMER_KEY']
CONSUMER_SECRET = ENV['CONSUMER_SECRET']
ACCESS_TOKEN = ENV['ACCESS_TOKEN']
ACCESS_TOKEN_SECRET = ENV['ACCESS_TOKEN_SECRET']

# @return [Twitter::REST::Client]
def get_twitter
  Twitter::REST::Client.new do |cfg|
    cfg.consumer_key = CONSUMER_KEY
    cfg.consumer_secret = CONSUMER_SECRET
    cfg.access_token = ACCESS_TOKEN
    cfg.access_token_secret = ACCESS_TOKEN_SECRET
  end
end

get_twitter.friends

def get_stream
  Twitter::Streaming::Client.new do |cfg|
    cfg.consumer_key = CONSUMER_KEY
    cfg.consumer_secret = CONSUMER_SECRET
    cfg.access_token = ACCESS_TOKEN
    cfg.access_token_secret = ACCESS_TOKEN_SECRET
  end
end