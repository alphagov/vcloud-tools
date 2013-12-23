module Vcloud
  module Core
    class Vdc

      attr_reader :id

      def self.get_by_name(name)

        fsi = Vcloud::Fog::ServiceInterface.new
        unless body = fsi.vdc(name)
          raise "Could not find vDC named '#{name}'"
        end
        self.new(body[:href].split('/').last)
      end

      def initialize(id)
        @id = id
      end

    end
  end
end
