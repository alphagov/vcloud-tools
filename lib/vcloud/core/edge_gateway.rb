module Vcloud
  module Core
    class EdgeGateway

      attr_reader :id

      def initialize(id)
        @id = id
      end

      def self.get_by_name(name)
        q = Query.new('edgeGateway', :filter => "name==#{name}")
        unless res = q.get_all_results
          raise "Error finding edgeGateway by name #{name}"
        end
        case res.size
        when 0
          raise "edgeGateway #{name} not found"
        when 1
          return self.new(res.first[:href].split('/').last)
        else
          raise "found multiple edgeGateway entities with name #{name}!"
        end
      end

      def body
        fsi = Vcloud::Fog::ServiceInterface.new
        fsi.get_edge_gateway(id)
      end

    end
  end
end
