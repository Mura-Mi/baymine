require 'logger'
require_relative '../lib/persister'

logger = Logger.new("log/count-#{Date.today.strftime('%Y-%m-%d')}.log")

count = Persister.new.driver[:tw_test].count()

logger.info("#{count} tweets was saved.")
