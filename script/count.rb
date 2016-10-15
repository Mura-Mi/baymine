require 'logger'
require_relative '../lib/persister'
require_relative '../lib/chat'

logger = Logger.new("log/count-#{Date.today.strftime('%Y-%m-%d')}.log")

count = Persister.new.driver[:tw_test].count()

logger.info("#{count} tweets was saved.")

BayMine::Chat.new.report_tw_count(count)
