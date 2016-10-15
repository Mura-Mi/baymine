require_relative('./analyze')

module BayMine
  class Tweet
    ANALYZER = BayMine::Analyzer.new

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
          keywords: {
              general: ANALYZER.count_keywords(@text),
              names: ANALYZER.count_person(@text)
          },
          created_at: @created_at
      }
    end
  end
end
