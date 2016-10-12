if require('dotenv')
  Dotenv.load
end

require 'mongo'

class Persister
  attr_reader :driver

  def initialize(url = nil)
    @driver = Mongo::Client.new(url || ENV['MONGO_URL'])
  end


end
