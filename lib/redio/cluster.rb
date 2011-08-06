module Redio
  class Cluster

    attr_accessor :nodes, :distributed_methods

    def initialize(nodes)
      @nodes = nodes
    end

    def method_missing(method_id, *args, &block)
      options = distributed_methods[method_id]
      command = DistributedCommand.new(nodes, options)
      command.execute(method_id, args, block)
      command.last_successful_response
    end

    def distribute(method_id, options)
      distributed_methods[method_id] = options
    end

    def distributed_methods
      @distributed_options ||= {}
    end

  end

  class DistributedCommand

    attr_accessor :failed_nodes, :successful_nodes, :nodes, :options

    def initialize(nodes, options)
      @nodes   = nodes
      @options = options
    end


    def minimum
      options[:minimum] || 1
    end

    def maximum
      options[:maximum]
    end

    def execute(method_id, args, block)
      nodes.each do |node|
        begin
          result = node.send(method_id, *args, &block)
          success!(node, result)
          break if done?
        rescue Exception => exception
          failure!(node, exception)
        end
      end

      raise exception if failed?
    end

    def done?
      maximum && maximum > successful_nodes.size
    end

    def failed?
      (nodes.size - failed_nodes.size) < minimum
    end

    def success!(node, result)
      self.successful_nodes[node] = result
    end

    def failure!(node, exception)
      self.failed_nodes[node] = exception
    end

    def last_successful_response
      successful_nodes.values.last
    end

    def failed_nodes
      @failed_nodes ||= {}
    end

    def successful_nodes
      @successful_nodes ||= {}
    end

  end
end
