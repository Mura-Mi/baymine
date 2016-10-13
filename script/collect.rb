require_relative '../lib/tw'
require_relative '../lib/tweet'
require_relative '../lib/persister'

tw = get_twitter

persister = Persister.new
col = persister.driver[:tw_test]

def need_to_persist(tw, col)
  !tw.retweet? && col.count({id: tw.id}) == 0
end

tw.search("ベイスターズ").each do |tweet|

  col.insert_one(BayMine::Tweet.new(tweet).to_hash) if need_to_persist(tweet, col)
end

