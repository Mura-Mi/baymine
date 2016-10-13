require_relative '../lib/tw'
require_relative '../lib/persister'

tw = get_twitter

persister = Persister.new

tw.search("ベイスターズ").each do |tweet|
  col = persister.driver[:tw_test]

  col.insert_one(BayMine::Tweet.new(tweet).to_hash) unless tweet.retweet? || col.count({id: tweet.id}) > 0
end

