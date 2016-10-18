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
  end
end