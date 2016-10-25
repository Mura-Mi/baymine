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

    def stop(level, format)
      @logger.send(level) { format % (millsec - @start) }
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

    def warn(obj, &block)
      if block_given?
        @logger.warn &block
      else
        @logger.warn obj
      end
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