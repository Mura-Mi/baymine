require 'natto'

module BayMine
  class Analyzer

    def initialize
      @natto = Natto::MeCab.new
    end

    def extract_keyword(sentence)
      nodes = []

      @natto.parse(sentence) do |node|
        nodes.push(node) unless unnecessary?(node)
      end

      nodes
    end

    private
    def unnecessary?(node)
      fts = node.feature.split(',')
      ['助詞', 'BOS/EOS'].include? fts[0] || fts[1] == '非自立'
    end

  end
end