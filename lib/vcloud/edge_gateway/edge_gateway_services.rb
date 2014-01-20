require 'json'
require 'yaml'
require 'fileutils'

module Vcloud
  class EdgeGatewayServices
    class << self

      def configure service_to_configure, settings_directory
        settings_source = EdgeGateway::FilesystemSettings.new(settings_directory)
        updater = EdgeGateway::SettingsUpdater.new(settings_source)

        updater.update(EdgeGateway::Services.const_get(service_to_configure.upcase))
      end

      def download_config download_dir
        org_settings_dir = File.join(download_dir || 'gateways/settings' ,
                                 Vcloud::Fog::ServiceInterface.new.org_name)

        init_settings_dir org_settings_dir

        source = EdgeGateway::VcloudServiceSettings.new
        source.get_settings { |gateway_name, service_name, settings|
          gateway_settings_dir = File.join(org_settings_dir, sanitize(gateway_name))
          FileUtils.mkdir_p(gateway_settings_dir)
          file_name = "#{sanitize(service_name.gsub(/service/, ''))}.yml"
          path = File.join(gateway_settings_dir, file_name)
          File.open(path, 'w') { |f| f.write(YAML::dump(settings.recursively_stringify_keys!)) }
          puts "Created: #{path}"
        }
      end

      def sanitize(string_value)
        string_value.gsub!(/[^a-zA-Z0-9\.\-\+_]/, "_")
        string_value
      end

      def init_settings_dir settings_dir
        FileUtils.mkdir_p(settings_dir)
      end

    end
  end
end
