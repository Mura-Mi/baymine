require_relative '../lib/persister'
require_relative '../lib/analyze'
require_relative '../lib/tweet'
require 'logger'

def millsec
  Time.now.instance_eval { self.to_i * 1000 + (usec / 1000) }
end

logger = Logger.new("log/analyze-#{Date.today.strftime('%Y-%m-%d')}.log")

start = millsec
count = 0

begin
  collection = Persister.new.driver[:tw_test]

  collection.find({
                      "$or": [
                          {"keywords": {"$exists": false}},
                          # TODO improve Sem-Var query
                          {"keywords.v.patch": {"$lt": BayMine::Analyzer.version[:patch]}}
                      ]
                  }).each do |tw|
    collection.update_one({_id: tw[:_id]}, BayMine::Tweet.new(tw).to_hash)
    count += 1
  end


rescue => e
  logger.fatal e
end

completed = millsec

logger.info("Analyzing #{count} tweet(s) has been completed in #{completed - start} msec.") if count > 0