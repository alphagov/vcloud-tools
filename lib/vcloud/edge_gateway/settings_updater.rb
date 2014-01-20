module Vcloud
  module EdgeGateway
    class SettingsUpdater

      def initialize(config_source)
        @config_source = config_source
      end

      def update(section)
        config = @config_source.get_config(section)
        config = config.recursively_symbolize_keys!
        vcloud = ::Vcloud::Fog::ServiceInterface.new
        tries = 0
        begin
          vcloud.post_configure_edge_gateway_services config[:gateway_id], config
        rescue ::Fog::Compute::VcloudDirector::Unauthorized
          raise if tries >= 3
          tries += 1
          sleep 1
          retry
        end
      end
    end
  end
end
