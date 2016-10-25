require_relative '../lib/tw'
require_relative '../lib/persister'
require_relative '../lib/zatsu_logger'

limit = if ARGV[0]
          ARGV[0].to_i
        else
          50;
        end

logger = BayMine::LogMan.new("extract-user")

begin
  p = Persister.new
  users = p.user_repository
  tweets = p.tweet_repository

  tw = get_twitter

  logger.start
  user_list = users.distinct(:user)
  logger.stop(:info, "select distinct username from tweets completed in %s msec.")

  tweets.distinct(:user).each { |username|
    users.update_one({user: username}, {"$set": {user: username}}, {upsert: true}) unless user_list.include?(username)
  }

  logger.start
  count = 0

  users.find({user_id: {"$exists": false}}).take(limit).each do |u|
    username = u[:user]
    user_in_twitter = tw.users(username).find { |twuser| twuser.screen_name.downcase == username }

    if user_in_twitter
      users.update_one({user: username}, {"$set": {user_id: user_in_twitter.id}})
      count += 1
    end

  end

  logger.stop(:info, "#{count} users has been updated to be assigned userid in %s msec.")

rescue => e
  logger.fatal e
end

