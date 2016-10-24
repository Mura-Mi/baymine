require_relative '../lib/persister'
require_relative '../lib/utils'
require 'logger'
require 'nmatrix'

logger = Logger.new("log/cluster-#{Date.today.strftime('%Y-%m-%d')}.log")

persister = Persister.new

user_repository = persister.user_repository

clustor_count = BayMine::Utils.arg_to_int(0, 20)
limit = BayMine::Utils.arg_to_int(1, 2_000)
init_clustor_size = BayMine::Utils.arg_to_int(1, 1)

logger.info {
  "Start extracting clustor: #{clustor_count} clusters with #{limit} users."
}

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

users = user_repository.find.limit(limit).to_a
uc = users.count

all_words = []
users.each do |u|
  u[:tf_idf].keys.each { |k| all_words << k }
end

all_words = all_words.uniq!.sort!.freeze
dim = all_words.count

logger.debug { "Analysis dimension: #{dim}" }

start = Time.now
user_vec = users.map.with_index { |user, i|
  vec = Array.new(all_words.count) { 0.0 }
  user[:tf_idf].each do |word, value|
    idx = all_words.bsearch_index { |el| el >= word }
    vec[idx] = value
  end

  logger.debug {
    "#{i + 1} / #{uc}, user: #{user[:user]}"
  } if (i + 1) % 100 == 0 || (i + 1) == uc

  [user[:user], N[vec]]
}.to_h
logger.debug { "User data load completed in #{Time.now - start} sec." }

# Initial Cluster
start = Time.now
user_vec.take(clustor_count * init_clustor_size).each_with_index do |(u, v), i|
  builders[i % clustor_count].add(u, v)
end
logger.debug { "Initial clustor created in #{Time.now - start} seconds." }

none_moved = false

count = 0
user_belong_to = {}
prev_gravities = nil

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
        min_distance = distance
        nearest = n_th
      end
    }

    builders[nearest].add(u, v)
    none_moved = none_moved && !(user_belong_to[u].nil?) && user_belong_to[u] == nearest
    user_belong_to[u] = nearest

    # logger.debug("#{u}: #{user_belong_to[u]}")

    u_count += 1
    logger.debug {
      "user evaluation #{u_count} / #{uc} completed."
    } if u_count % 10 == 0 || u_count == uc
  end

  count += 1
  logger.debug { "#{count}th loop end." }
  logger.debug { "Cluster count: #{builders.map { |b| b.users.count }}" }
  logger.debug {
    norms = gravities.map.with_index { |g, iii|
      (g - prev_gravities[iii]).nrm2
    }
    "Gravity movement: #{norms}"
  } if prev_gravities != nil
  prev_gravities = gravities
end

result = builders.map { |b| b.grav_vector(dim) }
logger.debug result
puts result
