require_relative '../lib/persister'
require_relative '../lib/utils'
require 'logger'

logger = Logger.new(STDOUT)

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

  def clear
    @users.clear
    @tf_idf_sum.clear
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

logger.debug { builders.map { |b| b.users.count } }

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
      logger.debug { "#{u[:user]}, #{n_th}" }
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
