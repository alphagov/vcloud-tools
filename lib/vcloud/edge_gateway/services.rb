module Vcloud
  module EdgeGateway

    class Services

      FIREWALL = "FirewallService"
      NAT = "NatService"
      LOADBALANCER = "LoadBalancerService"
      DHCP = "GatewayDhcpService"
      IPSEC = "GatewayIpsecVpnService"
      ALL = [FIREWALL, NAT, LOADBALANCER, DHCP, IPSEC]

    end

  end
end
