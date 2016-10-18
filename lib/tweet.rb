require_relative('./analyze')
require 'twitter/tweet'
require 'bson/document'

module BayMine
  class Tweet
    ANALYZER = BayMine::Analyzer.new

    def initialize(tweet)
      if tweet.is_a? Twitter::Tweet
        @id = tweet.id
        @text = tweet.text
        @user = tweet.user.screen_name
        @user_id = tweet.user.id
        @fav = tweet.favorite_count
        @rt = tweet.retweet_count
        @created_at = tweet.created_at
      elsif tweet.is_a? BSON::Document
        @id = tweet[:id]
        @text = tweet[:text]
        @user = tweet[:user]
        @user_id = tweet[:user_id]
        @fav = tweet[:fav]
        @rt = tweet[:rt]
        @created_at = tweet[:created_at]
      end
    end

    def to_hash
      {
          id: @id,
          text: @text,
          user: @user,
          user_id: @user_id,
          fav: @fav,
          rt: @rt,
          keywords: ANALYZER.analyze(@text),
          created_at: @created_at
      }
    end
  end
end
