require 'fog'
require 'vcloud'

module Vcloud
  class MissingVappsForVdc

    def initialize(vdc_name, query_runner, vapps_config)
      @query_runner = query_runner
      @env_vapp_names = env_vapp_names(vdc_name)
      @config_vapp_names = config_vapp_names(vapps_config)
    end

    def from_config
      @env_vapp_names - @config_vapp_names
    end

    def from_environment
      @config_vapp_names - @env_vapp_names
    end

    private

    def config_vapp_names(vapps_config)
      extract_names(vapps_config.vapps)
    end

    def env_vapp_names(vdc_name)
      env_vapps = get_vapps_from_env(vdc_name)
      extract_names(env_vapps)
    end

    def get_vapps_from_env(vdc_name)
      check_vdc_exists(vdc_name)
      @query_runner.run('vApp', {:filter => "vdcName==#{vdc_name}"})
    end

    def check_vdc_exists(vdc_name)
      raise Vcloud::VdcNotFoundError unless @query_runner.run('orgVdc', {:filter => "name==#{vdc_name}"}).size == 1
    end

    def extract_names(vapps_list)
      vapps_list.collect { |vapp| vapp[:name] }
    end

  end
end
