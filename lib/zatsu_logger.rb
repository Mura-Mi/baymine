require 'logger'

module BayMine


  class LogMan

    attr_reader :logger

    def initialize(name)
      @logger = Logger.new("log/#{name}-#{Date.today.strftime('%Y-%m-%d')}.log")
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

    def running?
      @running
    end

    private

    def millsec
      Time.now.instance_eval { self.to_i * 1000 + (usec / 1000) }
    end

  end
end