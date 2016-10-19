require_relative '../lib/persister'
require_relative '../lib/utils'
require 'logger'

p = Persister.new
users = p.user_repository
tweets_repo = p.tweet_repository

user_words = {}
all_words = {}

all_freq = {}

def millsec
  Time.now.instance_eval { self.to_i * 1000 + (usec / 1000) }
end

logger = Logger.new("log/tf-idf-#{Date.today.strftime('%Y-%m-%d')}.log")

begin
  start = millsec

  # Count Appearance of each words
  users.find.limit(30).each do |user|
    username = user[:user]
    words = {}
    tweets_repo.find({user: username}).each { |t|
      t[:keywords][:general].each { |k, v|
        words[k] = words[k].to_i + v
        all_words[k] = all_words[k].to_i + v
        all_freq[k] = all_words[k].to_i + 1
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

  size = users.count

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
    users.update_one({user: user}, {"$set": { tf_idf: tf_idf, tf_idf_created_at: Time.now }})
  end

  fin = millsec
  logger.info "Refining #{size} user's TF-IDFs is completed in #{fin - start} msec."
rescue => e
  logger.fatal e
end
