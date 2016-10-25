require_relative '../lib/zatsu_logger'
require_relative '../lib/persister'
require_relative '../lib/chat'

logger = BayMine::LogMan.new("count")

begin
  count = Persister.new.driver[:tw_test].count()

  logger.info{ "#{count} tweets was saved." }

  BayMine::Chat.new.report_tw_count(count)
rescue => e
  logger.fatal e
end
