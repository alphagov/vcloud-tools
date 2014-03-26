module Vcloud
  class VappConfig

    def initialize(vdc_config_dir, config_loader = Vcloud::Core::ConfigLoader.new)
      @vdc_config_dir = vdc_config_dir
      @config_loader = config_loader
    end

    def vapps
      config_files = vdc_config_files(@vdc_config_dir)
      all_vapps_in_config(config_files)
    end

    private

    def vdc_config_files(vdc_config_dir)
      Dir.glob(File.join(vdc_config_dir, '*.yaml'))
    end

    def all_vapps_in_config(config_files)
      config_files.collect { |config_file| @config_loader.load_config(config_file)[:vapps] }.flatten
    end

  end
end
