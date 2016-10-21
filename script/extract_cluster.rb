require_relative '../lib/persister'
require_relative '../lib/utils'

persister = Persister.new

user_repository = persister.user_repository

clustor_count = BayMine::Utils.arg_to_int(0, 20)

class GravityBuilder
  attr_reader :users

  def initialize
    @users = []
    @tf_idf_sum = {}
  end

  def add(user)
    @users << user
    user[:tf_idf].each do |word, value|
      @tf_idf_sum[word] = @tf_idf_sum[word].to_f + value
    end
  end

  def grav_vector
    count = @users.size
    @tf_idf_sum.map { |word, value|
      [word, value / count]
    }.to_h
  end
end

builders = (0...clustor_count).map { GravityBuilder.new }

users = user_repository.find.to_a
users.each do |u|
  builders.sample.add(u)
end

gravities = builders.map { |b| b.grav_vector }

users.each do |u|
  # Calc distance
end

