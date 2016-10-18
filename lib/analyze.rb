require 'natto'
require 'uri'

module BayMine
  class Analyzer

    # Analyzing Scheme Version (Semantic Version)
    MAJOR = 0
    MINOR = 0
    PATCH = 7

    def self.version
      {
          major: MAJOR,
          minor: MINOR,
          patch: PATCH
      }
    end

    def self.version_lt(prefix = "")
      pf = nil
      if prefix.empty?
        pf = prefix
      else
        pf = prefix + "."
      end
      {
          "$or": [
              {"#{pf}major": {"$lt": MAJOR}},
              {"$and": [
                  {"#{pf}major": {"$eq": MAJOR}},
                  {"$or": [
                      {"#{pf}minor": {"$lt": MINOR}},
                      {"$and": [
                          {"#{pf}minor": {"$eq": MINOR}},
                          {"#{pf}patch": {"$lt": PATCH}}
                      ]}
                  ]}
              ]}
          ]
      }
    end

    def initialize
      @natto = Natto::MeCab.new
    end

    def analyze(sentence)
      urls = urls(sentence)
      {
          v: Analyzer.version,
          general: count_keywords(sentence, urls),
          names: count_person(sentence),
          urls: urls
      }
    end

    private

    def urls(sentence)
      URI.extract(sentence).select { |url| url =~ /^http/ }
    end

    def count_keywords(sentence, urls = [])
      nodes = {}

      # make string mutable
      s = String.new(sentence)
      urls.each { |url| s.gsub!(url, "") }

      extract_nodes(s).each do |node|
        term = extract_term(node)
        nodes[term] = (nodes[term] || 0) + 1
      end

      nodes
    end

    def count_person(sentence)
      names = {last: {}, first: {}, unknown: {}}

      extract_nodes(sentence).each do |node|

        surface = node.surface

        if last_name?(node)
          names[:last][surface] = (names[surface] || 0) + 1
        elsif first_name?(node)
          names[:first][surface] = (names[surface] || 0) + 1
        elsif name?(node)
          names[:unknown][surface] = (names[surface] || 0) + 1
        end

      end

      names
    end

    def extract_nodes(sentence)
      nodes = []
      @natto.parse(sentence) do |node|
        nodes << node unless unnecessary?(node)
      end
      nodes
    end

    def unnecessary?(node)
      fts = node.feature.split(',')
      %w(助詞 助動詞 記号 BOS/EOS).include?(fts[0]) ||
          fts[1] == '非自立' ||
          node.surface.include?(".") ||
          node.surface[0] == "$" ||
          node.surface == "@"
    end

    def extract_term(node)
      features = node.feature.split(',')
      if features[0] == "動詞"
        features[6]
      else
        node.surface
      end
    end

    def last_name?(node)
      node.feature.split(',')[3] == '姓'
    end

    def first_name?(node)
      node.feature.split(',')[3] == '名'
    end

    def name?(node)
      node.feature.split(',')[2] == '人名'
    end

  end
end