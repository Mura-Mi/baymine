require_relative '../lib/persister'
require_relative '../lib/utils'
require 'logger'
require 'nmatrix'

logger = Logger.new(STDOUT)

persister = Persister.new

user_repository = persister.user_repository

clustor_count = BayMine::Utils.arg_to_int(0, 20)

class GravityBuilder
  attr_reader :users

  def initialize
    @users = []
    @tf_idf_sum = nil
  end

  def add(user, vec)
    @users << user
    # user[:tf_idf].each do |word, value|
    #   @tf_idf_sum[word] = @tf_idf_sum[word].to_f + value
    # end
    @tf_idf_sum = @tf_idf_sum + vec
  end

  def clear
    @users.clear
    @tf_idf_sum = nil
  end

  def grav_vector
    @tf_idf_sum / @users.size
  end
end

builders = (0...clustor_count).map { GravityBuilder.new }

users = user_repository.find.to_a
uc = users.count

all_words = []
users.each do |u|
  u[:tf_idf].keys.each { |k| all_words << k }
end

all_words.uniq!.sort!.freeze

user_vec = users.map.with_index { |user, i|
  vec = N[Array.new(all_words.count) { 0.0 }]
  user[:tf_idf].each do |word, value|
    vec[all_words.index(word)] = value
  end
  [user[:name], vec]

  logger.debug { "#{i} / #{uc}, user: #{user[:user]}" }
}

user_vec.each do |u, v|
  builders.sample.add(u, v)
end

logger.debug { builders.map { |b| b.users.count } }
# logger.debug { user_vec }

none_moved = false

count = 0
until none_moved do
  gravities = builders.map { |b| b.grav_vector }
  builders.each { |b| b.clear }

  none_moved = true

  users.each do |u|
    min_distance = nil
    nearest = nil

    logger.debug u[:user]

    gravities.map.with_index { |g, n_th|
      distance = BayMine::Utils.calc_distance(g, u[:tf_idf])
      logger.debug { "#{n_th} for #{u[:user]}" }
      if min_distance.nil? || min_distance > distance
        none_moved = false
        min_distance = distance
        nearest = n_th
      end
    }

    builders[nearest].add(u)
  end

  count += 1
  logger.debug { "#{count}th loop end." }
  logger.debug { builders.map { |b| b.users.count } }
end

puts builders.map { |b| b.grav_vector }
