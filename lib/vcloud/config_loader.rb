require 'vcloud'

module Vcloud
  class ConfigLoader

    def load_config(config_file)
      config = YAML::load(File.open(config_file))

      # There is no way in YAML or Ruby to symbolize keys in a hash
      json_string = JSON.generate(config)
      JSON.parse(json_string, :symbolize_names => true)
    end

    def validate_config(config)
      pre = 'ConfigLoader.validate_config'
      raise "#{pre}: config cannot be nil" if config.nil?
      raise "#{pre}: config must be a parameter hash" unless config.is_a? Hash
      raise "#{pre}: config cannot be empty" if config.empty?

      if config.key?(:vapps)

        vapps = config[:vapps]

        vapps.each do |vapp_config|

          raise "#{pre}: vapp config cannot be nil" if vapp_config.nil?
          raise "#{pre}: vapp config must be a parameter hash" unless vapp_config.is_a? Hash
          raise "#{pre}: vapp config cannot be empty" if vapp_config.empty?

          [ 'name', 'vdc_name', 'catalog', 'catalog_item'].each do |p|
            unless vapp_config.key?(p.to_sym) && ! vapp_config[p.to_sym].empty?
              raise "#{pre}: #{p} must be specified" unless vapp_config.key?(p.to_sym)
            end
          end

          if vapp_config.key?(:vm)
            vm_config = vapp_config[:vm]
            raise "#{pre}: vm config must be a hash" unless vm_config.is_a? Hash
            raise "#{pre}: vm config must not be empty" if vm_config.empty?
          end
        end

      end

      config
    end

  end 
end
