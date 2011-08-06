module Redio
  class Attributes

    def initialize(key)
      @key = attributes.fetch(:key)
    end

    def [](key)
      redis.hget(namespace(key))
    end

    def []=(key, value)
      redis.hset(namespace(key), value)
    end

    def namespace(key)
      "redio/#{key}/attributes"
    end

  end
end
