if require('dotenv')
  Dotenv.load
end

require 'mongo'

class Persister
  def initialize(url = nil)
    @driver = Mongo::Client.new(url || ENV['MONGO_URL'])
  end


end
