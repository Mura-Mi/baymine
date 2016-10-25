require_relative '../lib/persister'
require_relative '../lib/utils'
require_relative '../lib/zatsu_logger'

p = Persister.new
users = p.user_repository
tweets_repo = p.tweet_repository

user_words = {}
all_freq = {}

limit = BayMine::Utils.arg_to_int(0, 2 ** 30)

logger = BayMine::LogMan.new("tf-idf")

begin
  logger.start

  # Count Appearance of each words
  users.find.limit(limit).each do |user|
    username = user[:user]
    words = {}
    tweets_repo.find({user: username}).each { |t|
      t[:keywords][:general].each { |k, v|
        words[k] = words[k].to_i + v
        all_freq[k] = all_freq[k].to_i + 1
      }
    }
    user_words[username] = words
  end

  # Term Frequency ( log(N)+1 )
  user_tfs = user_words.map { |user, words|
    tf = words.map { |word, freq|
      [word, Math.log10(freq) +1]
    }.to_h
    [user, tf]
  }.to_h

  size = user_tfs.count

  user_idfs = user_words.map { |user, words|
    idf = words.keys.map { |word|
      [word, size / (all_freq[word].to_i || 1)] # in case of all_freq = nil
    }.to_h
    [user, idf]
  }.to_h

  user_tf_idfs = user_tfs.map { |user, tfs|
    idfs = user_idfs[user]
    return if idfs.nil? || idfs.empty?
    tf_idfs = tfs.map { |word, tf|
      [word, tf * idfs[word].to_f]
    }.to_h
    [user, tf_idfs]
  }.to_h

  user_tf_idfs.each do |user, tf_idf|
    users.update_one({user: user}, {"$set": {tf_idf: tf_idf, tf_idf_created_at: Time.now}})
  end

  logger.stop { "Refining #{size} user's TF-IDFs is completed in %s msec." }
rescue => e
  logger.fatal e
end
