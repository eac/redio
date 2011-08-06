module Redio
  class Tempfile < File
    include IO
    include Expiration

    # 3 days
    self.default_expiration = 3 * 86400

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
