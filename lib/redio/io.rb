module Redio
  module IO

    attr_accessor :key, :redis, :position

    def each(length = 524_288)
      while data = read(length) do
        break if data.empty?
        yield data
      end
    end

    def write(data)
      result = redis.append(namespace(key), data)
      self.position += data.size
      result
    end

    def read(length)
      data  = redis.getrange(namespace(key), position, position + length).to_s
      self.position += data.size
      data
    end

    def size
      redis.strlen(namespace(key))
    end

    def close
    end

    def position
      @position ||= 0
    end

    def namespace(key)
      "redio/#{key}"
    end

    def rewind
      self.position = 0
    end

  end
end
