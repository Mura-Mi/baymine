require 'slack-ruby-client'
require 'dotenv'

Dotenv.load

Slack.configure do |cfg|
  cfg.token = ENV['SLACK_KEY']
end

module BayMine
  class Chat

    def initialize
      @slack = Slack::Web::Client.new
    end

    def ping
      @slack.chat_postMessage(channel: "#general", text: "It's a lonely road at #{Time.now}", as_user: true)
    end

    def report_tw_count(count)
      @slack.chat_postMessage(channel: "#count", text: "Now #{count} tweets in strage.", as_user: true)
    end

    def finish_extract_cluster(second, c)
      @slack.chat_postMessage(channel: "#cluster", text: "Cluster \##{c} extract completed in #{(second / 60).to_i} minutes #{(second % 60).to_i} seconds.", as_user: true)
    end
  end
end