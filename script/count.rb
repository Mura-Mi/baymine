require 'logger'
require_relative '../lib/persister'

class BayMine::Count
  class << self
    def exec

      logger = Logger.new("log/count-#{Date.today.strftime('%Y-%m-%d')}.log")

      count = Persister.new.driver[:tw_test].count()

      logger.info("#{count} tweets was saved.")

    end
  end
end
