module Redio
  class CorruptIO < StandardError
  end

  class ErrorDetector
    autoload :Digest, 'digest'

    attr_accessor :digest, :verifier
    attr_reader   :new_digest

    def initialize(key, options)
      @key      = key
      @digest   = options.fetch(:digest)
      @verifier = options[:verifier]
      @node     = node
    end

    def subscribe(node)
      node.on(:getrange, key) do
        @new_digest << result
      end

      node.on(:append, key) do
        @new_digest << value
      end
    end

    def <<(data)
      new_digest << data
    end

    def new_digest
      @new_digest ||= verifier.new
    end

    def verifier
      @verifier ||= Digest::MD5
    end

    def verify!
      if digest == new_digest
        attributes[:digest] = verification.new_digest
      else
        raise(CorruptIO.new("digest mismatch: #{digest} expected but was #{new_digest}")
      end
    end

  end
end
