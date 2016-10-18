require_relative '../lib/persister'

p = Persister.new
users = p.user_repository
tweets_repo = p.tweet_repository

user_words = {}
all_words = {}

users.find.limit(15).each do |user|
  username = user[:user]
  words = {}
   tweets_repo.find({user: username}).each { |t|
     t[:keywords][:general].each { |k, v|
       words[k] = words[k].to_i + v
       all_words[k] = all_words[k].to_i + v
     }
  }
  user_words[username] = words
end

