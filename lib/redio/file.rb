module Redio
  class File
    include IO

    def self.open(key, options = {})
      new(key, options).tap do |io|
        yield io
      end
    end

    def initialize(key, options)
      self.key      = key
      self.redis    = options.fetch(:redis)
    end

  end
end
