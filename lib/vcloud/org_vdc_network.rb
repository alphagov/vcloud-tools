module Vcloud
  class OrgVdcNetwork

    def initialize(id)
      @id = id
    end

    def self.get_by_name(name)
      q = Query.new('orgVdcNetwork', :filter => "name==#{name}")
      unless res = q.get_all_results
        raise "Error finding orgVdcNetwork by name #{name}"
      end
      case res.size
      when 0
        raise "orgVdcNetwork #{name} not found"
      when 1
        return self.new(res.first[:href].split('/').last)
      else
        raise "found multiple orgVdcNetwork with name #{name}!"
      end
    end

    def self.provision(config)
      fsi = Vcloud::FogServiceInterface.new
      raise "Must specify a name" unless name = config[:name]
      raise "Must specify a vdc_name" unless vdc_name = config[:vdc_name]

      unless config[:fence_mode] == 'isolated' || config[:fence_mode] == 'natRouted'
        raise "fence_mode #{config[:fence_mode]} not supported"
      end

      vdc = Vcloud::Vdc.get_by_name(vdc_name)

      options = construct_network_options(config)

      begin
        Vcloud.logger.info("Provisioning new OrgVdcNetwork #{name} in vDC '#{vdc_name}'")
        fsi.post_create_org_vdc_network(vdc.id, name, options)
      rescue RuntimeError => e
        Vcloud.logger.error("Could not provision orgVdcNetwork: #{e.message}")
      end

      org_net = self.get_by_name(name)

    end

    private

    def self.construct_network_options(config)
      opts = {
        :IsShared => config[:is_shared],
        :FenceMode => config[:fence_mode],
      }
    end

  end
end
