module BayMine
  class Tweet
    def initialize(tweet)
      @id = tweet.id
      @text = tweet.text
      @user = tweet.user.screen_name
      @fav = tweet.favorite_count
      @rt = tweet.retweet_count
      @created_at = tweet.created_at
    end

    def to_hash
      {
          id: @id,
          text: @text,
          user: @user,
          fav: @fav,
          rt: @rt,
          created_at: @created_at
      }
    end
  end
end
