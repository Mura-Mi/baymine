require 'logger'

module BayMine


  class LogMan

    attr_reader :logger

    def initialize(name)
      @logger = Logger.new("log/#{name}.log", 'daily')
      @start = nil
      @running = false
    end

    def start
      @start = millsec
      @running = true
    end

    def end(level, format)
      # TODO method dynamic invoke to define log level
      @logger.info { format % (millsec - @start) }
      @start = nil
      @running = false
    end

    def fatal(obj, &block)
      if block_given?
        @logger.fatal &block
      else
        @logger.fatal obj
      end
    end

    def info(&block)
      @logger.info &block
    end

    def debug(&block)
      @logger.debug &block
    end

    def running?
      @running
    end

    private

    def millsec
      Time.now.instance_eval { self.to_i * 1000 + (usec / 1000) }
    end

  end
end