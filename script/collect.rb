require_relative '../lib/tw'
require_relative '../lib/persister'

tw = get_twitter

persister = Persister.new

tw.search("ベイスターズ").each do |tweet|
  persister[:tw_test].insert_one({
                                     id: tweet.id,
                                     text: tweet.text,
                                     user: tweet.user.screen_name,
                                     fav: tweet.favorite_count,
                                     rt: tweet.retweet_count
                                 })
end

