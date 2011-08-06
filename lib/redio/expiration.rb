module Redio
  module Expiration

    attr_accessor :expiration

    def close
      super
      expire(expiration)
    end

    def expiration
      @expiration ||= self.class.default_expiration
    end

    def expire(expiration)
      redis.expire(namespace(key), expiration)
    end

    def ttl
      redis.ttl(namespace(key))
    end

  end
end
