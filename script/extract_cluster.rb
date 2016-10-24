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
    @tf_idf_sum = (@tf_idf_sum || N[Array.new(vec.size) { 0.0 }]) + vec
  end

  def clear
    @users.clear
    @tf_idf_sum = nil
  end

  def grav_vector(dim)
    if @tf_idf_sum
      @tf_idf_sum / @users.size
    else
      N[Array.new(dim) { 0.0 }]
    end
  end
end

builders = (0...clustor_count).map { GravityBuilder.new }

users = user_repository.find.limit(1_000).to_a
uc = users.count

all_words = []
users.each do |u|
  u[:tf_idf].keys.each { |k| all_words << k }
end

all_words = all_words.uniq!.sort!.freeze
# logger.debug all_words
dim = all_words.count

start = Time.now
user_vec = users.map.with_index { |user, i|
  vec = Array.new(all_words.count) { 0.0 }
  user[:tf_idf].each do |word, value|
    idx = all_words.bsearch_index { |el| el >= word }
    vec[idx] = value
  end
  logger.debug { "#{i + 1} / #{uc}, user: #{user[:user]}" }

  [user[:user], N[vec]]
}.to_h
logger.debug { "User data load completed in #{Time.now - start} sec." }

user_vec.take(clustor_count).each_with_index do |(u, v), i|
  builders[i % clustor_count].add(u, v)
end

none_moved = false

count = 0
until none_moved do
  gravities = builders.map { |b| b.grav_vector(dim) }
  builders.each { |b| b.clear }

  none_moved = true

  u_count = 0
  user_vec.each do |u, v|
    min_distance = nil
    nearest = nil

    gravities.map.with_index { |g, n_th|
      distance = (g - v).nrm2
      if min_distance.nil? || min_distance > distance
        none_moved = false
        min_distance = distance
        nearest = n_th
      end
    }

    builders[nearest].add(u, v)

    u_count += 1
    logger.debug {
      "user evaluation #{u_count} / #{uc} completed."
    } if u_count % 10 == 0 || u_count == uc
  end

  count += 1
  logger.debug { "#{count}th loop end." }
  logger.debug { builders.map { |b| b.users.count } }
end

puts builders.map { |b| b.grav_vector }
