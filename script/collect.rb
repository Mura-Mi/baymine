require_relative '../lib/tw'
require_relative '../lib/persister'

tw = get_twitter

persister = Persister.new

tw.search("ベイスターズ").each do |tweet|
  col = persister.driver[:tw_test]

  col.insert_one({
                     id: tweet.id,
                     text: tweet.text,
                     user: tweet.user.screen_name,
                     fav: tweet.favorite_count,
                     rt: tweet.retweet_count,
                     created_at: tweet.created_at
                 }) unless tweet.retweet? || col.count({id: tweet.id}) > 0
end

