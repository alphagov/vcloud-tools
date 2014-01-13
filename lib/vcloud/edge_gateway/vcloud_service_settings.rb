module Vcloud
  module EdgeGateway
    class VcloudServiceSettings

      def get_settings
        ::Vcloud::Fog::ServiceInterface.new().get_edgegateways_in_org.each { |gateway|
          gateway_name = gateway[:name]
          services = gateway[:Configuration][:EdgeGatewayServiceConfiguration]
          service_names = services.keys
          service_names.each { |service_name|
            yield gateway_name,
                service_name.to_s.downcase,
                {:gateway_id => gateway[:id].gsub(/urn:vcloud:gateway:/, ''),
                 service_name => services[service_name]}
          }
        }
      end
    end
  end

end
