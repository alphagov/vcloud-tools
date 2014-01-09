require 'vcloud'

module Vcloud
  class ConfigLoader

    def load_config(config_file)
      config = YAML::load(File.open(config_file))

      # There is no way in YAML or Ruby to symbolize keys in a hash
      json_string = JSON.generate(config)
      validate_config(JSON.parse(json_string, :symbolize_names => true))
    end

    def validate_config(config)
      pre = 'ConfigLoader.validate_config'
      raise "#{pre}: config cannot be nil" if config.nil?
      raise "#{pre}: config must be a parameter hash" unless config.is_a? Hash
      raise "#{pre}: config cannot be empty" if config.empty?

      valid_parameters = [
        :anchors,
        :defaults,
        :vapps,
        :vdcs,
        :org_vdc_networks,
      ]
      config.each do |k,v|
        unless valid_parameters.include?(k)
          raise "#{pre}: '#{k.to_s}' is not a valid configuration parameter"
        end
      end

      if config.key?(:vapps)
        vapps = config[:vapps]
        vapps.each do |vapp_config|
          validate_vapp_config(vapp_config)
        end
      end

      config
    end

    def validate_vapp_config(config)
      pre = 'ConfigLoader.validate_vapp_config'
      raise "#{pre}: vapp config cannot be nil" if config.nil?
      raise "#{pre}: vapp config must be a parameter hash" unless config.is_a? Hash
      raise "#{pre}: vapp config cannot be empty" if config.empty?

      valid_parameters = [
        :name,
        :vdc_name,
        :catalog,
        :catalog_item,
        :vm,
      ]
      config.each do |k,v|
        unless valid_parameters.include?(k)
          raise "#{pre}: '#{k.to_s}' is not a valid configuration parameter"
        end
      end

      [ 'name', 'vdc_name', 'catalog', 'catalog_item'].each do |p|
        unless config.key?(p.to_sym) && ! config[p.to_sym].empty?
          raise "#{pre}: #{p} must be specified" unless config.key?(p.to_sym)
        end
      end

      validate_vm_config(config[:vm]) if config.key?(:vm)
      config
    end

    def validate_vm_config(config)
      pre = 'ConfigLoader.validate_vm_config'
      raise "#{pre}: vm config must be a hash" unless config.is_a? Hash
      raise "#{pre}: vm config must not be empty" if config.empty?
      valid_parameters = [
        :network_connections,
        :storage_profile,
        :hardware_config,
        :extra_disks,
        :bootstrap,
        :metadata,
      ]
      config.each do |k,v|
        unless valid_parameters.include?(k)
          raise "#{pre}: '#{k.to_s}' is not a valid configuration parameter"
        end
      end
      validate_metadata_config(config[:metadata]) if config.key?(:metadata)
      validate_vm_hardware_config(config[:hardware_config]) if config.key?(:hardware_config)
      config
    end

    def validate_metadata_config(config)
      pre = 'ConfigLoader.validate_metadata_config'
      raise "#{pre}: metadata config must be a hash" unless config.is_a? Hash
      config
    end

    def validate_vm_hardware_config(config)
      pre = 'ConfigLoader.validate_vm_hardware_config'
      raise "#{pre}: vm hardware_config must be a hash" unless config.is_a? Hash
      valid_parameters = [
        :cpu,
        :memory,
      ]
      config.each do |k,v|
        unless valid_parameters.include?(k)
          raise "#{pre}: '#{k.to_s}' is not a valid configuration parameter"
        end
      end
      config
    end

  end
end
