require_relative '../lib/persister'
require_relative '../lib/tw'
require 'logger'

limit = if ARGV[0]
          ARGV[0].to_i
        else
          50;
        end

logger = Logger.new("log/extract-user-#{Date.today.strftime('%Y-%m-%d')}.log")

def millsec
  Time.now.instance_eval { self.to_i * 1000 + (usec / 1000) }
end

begin
  p = Persister.new
  users = p.user_repository
  tweets = p.tweet_repository

  tw = get_twitter

  start = millsec
  user_list = users.distinct(:user)
  fin = millsec
  logger.info("select distinct username from tweets completed in #{fin - start} msec.")

  tweets.distinct(:user).each { |username|
    users.update_one({user: username}, {"$set": {user: username}}, {upsert: true}) unless user_list.include?(username)
  }

  start = millsec
  count = 0

  users.find({user_id: {"$exists": false}}).take(limit).each do |u|
    username = u[:user]
    user_in_twitter = tw.user_search(username).find { |twuser| twuser.screen_name.downcase == username }

    users.update_one({user: username}, {"$set": {user_id: user_in_twitter.id}}) if user_in_twitter

    count += 1
  end

  fin = millsec
  logger.info("#{count} users has been updated to be assigned userid in #{fin - start} msec.")

rescue => e
  logger.fatal e
end

