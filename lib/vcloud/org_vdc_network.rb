module Vcloud
  class OrgVdcNetwork

    attr_reader :id

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
      fsi = Vcloud::Fog::ServiceInterface.new
      raise "Must specify a name" unless name = config[:name]
      raise "Must specify a vdc_name" unless vdc_name = config[:vdc_name]

      unless config[:fence_mode] == 'isolated' || config[:fence_mode] == 'natRouted'
        raise "fence_mode #{config[:fence_mode]} not supported"
      end

      unless config[:is_shared]
        config[:is_shared] = false
      end

      if config[:fence_mode] == 'natRouted'
        raise "Must specify an edge_gateway to connect to" unless config.keys?(:edge_gateway)
        edgegw = Vcloud::EdgeGateway.get_by_name(config[:edge_gateway])
      end

      vdc = Vcloud::Vdc.get_by_name(vdc_name)

      options = construct_network_options(config)

      begin
        Vcloud.logger.info("Provisioning new OrgVdcNetwork #{name} in vDC '#{vdc_name}'")
        fsi.post_create_org_vdc_network(vdc.id, name, options)
      rescue RuntimeError => e
        Vcloud.logger.error("Could not provision orgVdcNetwork: #{e.message}")
      end

      self.get_by_name(name)

    end

    def delete
      fsi = Vcloud::Fog::ServiceInterface.new
      fsi.delete_network(id)
    end

    private

    def self.construct_network_options(config)
      opts = {}
      opts[:Description] = config[:description] if config.key?(:description)
      opts[:IsShared] = config[:is_shared]

      ip_scope = {}
      ip_scope[:IsInherited] = config[:is_inherited] || false
      ip_scope[:Gateway]     = config[:gateway] if config.key?(:gateway)
      ip_scope[:Netmask]     = config[:netmask] if config.key?(:netmask)
      ip_scope[:Dns1]        = config[:dns1] if config.key?(:dns1)
      ip_scope[:Dns2]        = config[:dns2] if config.key?(:dns2)
      ip_scope[:DnsSuffix]   = config[:dns_suffix] if config.key?(:dns_suffix)
      ip_scope[:IsEnabled]   = config[:is_enabled] || true

      opts[:Configuration] = {
        :FenceMode => config[:fence_mode],
        :IpScopes => {
          :IpScope => ip_scope
        },
      }

      opts
    end

  end
end
