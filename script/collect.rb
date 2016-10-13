require 'logger'
require 'date'
require_relative '../lib/tw'
require_relative '../lib/tweet'
require_relative '../lib/persister'

tw = get_twitter
logger = Logger.new("log/collect-#{Date.today.strftime('%Y-%m-%d')}.log")

persister = Persister.new
col = persister.driver[:tw_test]

def need_to_persist(tw, col)
  !tw.retweet? && col.count({id: tw.id}) == 0
end

count = 0

tw.search("ベイスターズ").each do |tweet|
  col.insert_one(BayMine::Tweet.new(tweet).to_hash) if need_to_persist(tweet, col)
  count += 1
end

logger.info("Persist #{count} tweets to collection tw_test")

