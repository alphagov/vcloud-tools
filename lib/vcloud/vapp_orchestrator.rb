module Vcloud
  class VappOrchestrator

    def self.provision(vapp_config)
      name, vdc_name = vapp_config[:name], vapp_config[:vdc_name]
      begin
        if vapp = Vcloud::Core::Vapp.get_by_name_and_vdc_name(name, vdc_name)
          Vcloud.logger.info("Found existing vApp #{name} in vDC '#{vdc_name}'. Skipping.")
        else
          template = Vcloud::Core::VappTemplate.get(vapp_config[:catalog], vapp_config[:catalog_item])
          template_id = template.id

          network_names = extract_vm_networks(vapp_config)
          vapp = Vcloud::Core::Vapp.instantiate(name, network_names, template_id, vdc_name)
          Vcloud::VmOrchestrator.new(vapp.fog_vms.first, vapp).customize(vapp_config[:vm]) if vapp_config[:vm]
          vapp
        end

      rescue RuntimeError => e
        Vcloud.logger.error("Could not provision vApp: #{e.message}")
      end
      vapp
    end

    def self.validate_vapp_config(config)
      pre = 'validate_vapp_config'
      raise "#{pre}: config cannot be nil" if config.nil?
      raise "#{pre}: config must be a parameter hash" unless config.is_a? Hash
      raise "#{pre}: config cannot be empty" if config.empty?
      [ 'name', 'vdc_name', 'catalog', 'catalog_item'].each do |p|
        unless config.key?(p.to_sym) && ! config[p.to_sym].empty?
          raise "#{pre}: #{p} must be specified" unless config.key?(p.to_sym)
        end
      end
      if config.key?(:vm)
        vm_config = config[:vm]
        raise "#{pre}: vm config must be a hash" unless vm_config.is_a? Hash
        raise "#{pre}: vm config must not be empty" if vm_config.empty?
      end

      true
    end

    def self.extract_vm_networks(config)
      if (config[:vm] && config[:vm][:network_connections])
        config[:vm][:network_connections].collect { |h| h[:name] }
      end
    end

  end
end
