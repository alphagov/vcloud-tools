module Vcloud
  module EdgeGateway

    class FilesystemSettings

      def initialize(settings_directory)
        @settings_directory = settings_directory
      end

      def get_config(section)
        gateway_config.select { |item|
          not item[section].nil?
        }.first
      end

      private

      def gateway_config
        init unless @settings
        @settings
      end

      def init
        @settings = []
        Dir.foreach(@settings_directory) { |f|
          next if f == '.' or f == '..'
          file = File.read(File.join(@settings_directory, f))
          @settings.push(YAML::load(file))
        }
      end

    end

  end
end
