require 'logger'
require 'date'
require_relative '../lib/tw'
require_relative '../lib/tweet'
require_relative '../lib/persister'

logger = Logger.new("log/collect-#{Date.today.strftime('%Y-%m-%d')}.log")

begin
  tw = get_twitter

  persister = Persister.new
  col = persister.driver[:tw_test]

  def need_to_persist(tw, col)
    !tw.retweet? && col.count({id: tw.id}) == 0
  end

  count = 0

  max_id = col.find.sort({id: -1}).limit(1).first[:id]

  tw.search("ベイスターズ", {since_id: max_id}).take(3000).each do |tweet|
    if need_to_persist(tweet, col)
      col.insert_one(BayMine::Tweet.new(tweet).to_hash)
      count += 1
    end
  end

  logger.info("Persist #{count} tweets to collection tw_test")
rescue => e
  logger.fatal e
end
