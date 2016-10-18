require_relative '../lib/persister'
require 'logger'

begin
  p = Persister.new
  users = p.user_repository
  tweets = p.tweet_repository

  tweets.distinct("user").each { |username|
    users.update_one({user: username}, {"$set": {user: username}}, {upsert: true})
  }

  tweets.find({user_id: {"$exists": true}}).each do |tw|
    users.update_one({user: tw[:user], user_id: {"$exists": false}}, {"$set": {user_id: tw[:user_id]}})
  end
rescue => e
  Logger.new("log/extract-user-#{Date.today.strftime('%Y-%m-%d')}.log").fatal e
end

