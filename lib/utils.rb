module BayMine
  module Utils
    def self.normalize(hash)
      raise "Argument must be Hash, but it is #{hash.class}" unless hash.is_a? Hash

      tmp = 0
      hash.each do |k, v|
        raise "All value should be number" unless v.is_a? Numeric
        tmp += v ** 2
      end

      length = Math.sqrt(tmp)

      hash.map { |k, v|
        [k, v / length]
      }.to_h
    end

    def self.arg_to_int(index, default = 0)
      if ARGV[index]
        ARGV[index].to_i
      else
        default
      end
    end

    def self.calc_distance(hash1, hash2)
      tmp = 0
      (hash1.keys | hash2.keys).each do |key|
        tmp += (hash1[key].to_f - hash2[key].to_f) ** 2
      end
      Math.sqrt(tmp)
    end
  end
end