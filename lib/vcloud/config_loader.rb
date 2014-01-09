require 'vcloud'

module Vcloud
  class ConfigLoader

    def load_config(config_file)
      config = YAML::load(File.open(config_file))

      # There is no way in YAML or Ruby to symbolize keys in a hash
      json_string = JSON.generate(config)
      validate_config(JSON.parse(json_string, :symbolize_names => true))
    end

    def check_data_against_schema(config, schema, pre)

      if schema.key?(:top)
        tls = schema[:top]
        raise "#{pre}: config cannot be nil" if config.nil? && tls[:allowed_nil] != true
        if type = tls[:type]
          raise "#{pre}: config must be a #{type}" unless config.is_a? type
        end
        unless tls[:allowed_empty] == true
          raise "#{pre}: config must not be empty" if config.empty?
        end
        if schema.key?(:params) && schema[:top][:check_for_bogus_params] != false
          check_for_bogus_parameters(config, schema[:params].keys, pre)
        end
      end

      if schema.key?(:params)
        schema[:params].each do |param,param_schema|
          unless param_schema[:required] == false
            raise "#{pre}: #{param} is required" unless config.key?(param)
          end
          if config.key?(param)
            param_config = config[param]
            unless param_schema[:allowed_nil] == true
              raise "#{pre}: #{param} cannot be nil" if param_config.nil?
            end
            if type = param_schema[:type]
              raise "#{pre}: #{param} must be a #{type}" unless param_config.is_a? type
            end
            unless param_schema[:allowed_empty] == true
              raise "#{pre}: #{param} must not be empty" if param_config.empty?
            end
            if param_schema.key?(:matches) && param_config !~ param_schema[:matches]
              raise "#{pre}: #{param} '#{param_config}' is not valid"
            end
            if param_schema.key?(:validator)
              self.send(param_schema[:validator], config[param])
            end
          end
        end
      end

    end

    def validate_config(config)
      pre = 'ConfigLoader.validate_config'
      schema = {
        top: { type: Hash, allowed_empty: false },
        params: {
          anchors:   { required: false, allowed_nil: true },
          defaults:  { required: false, allowed_nil: true },
          vapps:     { type: Array, required: false, allowed_empty: true,
            validator: :validate_vapps_config },
          org_vdc_networks: { type: Array, required: false, allowed_empty: true },
          vdcs:      { type: Array, required: false, allowed_empty: true },
        }
      }

      check_data_against_schema(config, schema, pre)

      config
    end

    def validate_vapps_config(config)
      config.each do |vapp_config|
        validate_vapp_config(vapp_config)
      end
    end

    def validate_vapp_config(config)
      pre = 'ConfigLoader.validate_vapp_config'
      schema = {
        top: { type: Hash, required: true, allowed_empty: false },
        params: {
          name:      { type: String, required: true, allowed_empty: false },
          vdc_name:  { type: String, required: true, allowed_empty: false },
          catalog:   { type: String, required: true, allowed_empty: false },
          catalog_item: { type: String, required: true, allowed_empty: false },
          vm: {
            type: Hash, required: false, allowed_empty: true,
            validator: :validate_vm_config,
          },
        }
      }
      check_data_against_schema(config, schema, pre)
      config
    end

    def validate_vm_config(config)
      pre = 'ConfigLoader.validate_vm_config'
      schema = {
        top: { type: Hash, required: true, allowed_empty: false },
        params: {
          network_connections: {
            type: Array,
            required: false,
            validator: :validate_vm_network_connections
          },
          storage_profile: { type: String, required: false },
          hardware_config: {
            type: Hash,
            required: false,
            validator: :validate_vm_hardware_config,
          },
          extra_disks: { required: false },
          bootstrap:   { required: false },
          metadata: {
            type: Hash,
            required: false,
            allowed_empty: true,
            validator: :validate_metadata_config,
          },
        }
      }
      check_data_against_schema(config, schema, pre)
      config
    end

    def validate_metadata_config(config)
      pre = 'ConfigLoader.validate_metadata_config'
      schema = {
        top: { type: Hash, required: true, allowed_empty: true },
      }
      check_data_against_schema(config, schema, pre)
      config
    end

    def validate_vm_hardware_config(config)
      pre = 'ConfigLoader.validate_vm_hardware_config'
      schema = {
        top: { type: Hash, required: true, allowed_empty: true },
        params: {
          cpu: { type: String, required: false, allowed_empty: false },
          memory: { type: String, required: false, allowed_empty: false },
        }
      }
      check_data_against_schema(config, schema, pre)
      config
    end

    def validate_vm_network_connections(config)
      pre = 'ConfigLoader.validate_vm_network_connections'
      schema = {
        top: { type: Array, required: true, allowed_empty: true },
      }
      entry_schema = {
        top: { type: Hash, required: true, allowed_empty: true },
        params: {
          name: { type: String, required: true, allowed_empty: false },
          ip_address: { type: String, required: false, allowed_empty: false,
            matches: /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/, },
        }
      }
      check_data_against_schema(config, schema, pre)
      config.each do |entry|
        check_data_against_schema(entry, entry_schema, pre)
      end
      config
    end

    private

    def check_for_bogus_parameters(config, valid_parameters, pre)
      config.each do |k,v|
        unless valid_parameters.include?(k)
          raise "#{pre}: '#{k.to_s}' is not a valid configuration parameter"
        end
      end
    end

  end
end
