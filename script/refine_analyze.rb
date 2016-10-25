require_relative '../lib/persister'
require_relative '../lib/analyze'
require_relative '../lib/tweet'
require_relative '../lib/zatsu_logger'
require_relative '../lib/utils'

logger = BayMine::LogMan.new("analyze")

logger.start
count = 0

limit = BayMine::Utils.arg_to_int(0, 30000)

begin
  collection = Persister.new.driver[:tw_test]

  collection.find({
                      "$or": [
                          {"keywords": {"$exists": false}},
                          BayMine::Analyzer.version_lt("keywords.v")
                      ]
                  }).limit(limit).each do |tw|
    collection.update_one({_id: tw[:_id]}, BayMine::Tweet.new(tw).to_hash)
    count += 1
  end


rescue => e
  logger.fatal e
end

ver = BayMine::Analyzer.version
logger.stop(:info,
            "Analyzing #{count} tweet(s) has been completed in %s msec. Updated to #{ver[:major]}.#{ver[:minor]}.#{ver[:patch]}") if count > 0