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

  tw.search("ベイスターズ").each do |tweet|
    col.insert_one(BayMine::Tweet.new(tweet).to_hash) if need_to_persist(tweet, col)
    count += 1
  end

  logger.info("Persist #{count} tweets to collection tw_test")
rescue => e
  logger.fatal "error occured while collecting tweets"
  logger.fatal e.inspect
  logger.fatal e.backtrace.join("\n")
end
