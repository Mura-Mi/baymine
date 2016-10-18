require_relative '../lib/persister'
require 'logger'


p = Persister.new
tws = p.tweet_repository

all = {}
tws.find.each do |tw|
  g = tw[:keywords][:general]
  (g || {}).each do |word, count|
    all[word] = all[word].to_i + count
  end
end

puts all
