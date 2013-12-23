require 'spec_helper'
require 'pp'

describe Vcloud::Core::OrgVdcNetwork do

  TEST_VDC      = ENV['VCLOUD_TEST_VDC']
  TEST_EDGE_GATEWAY = ENV['VCLOUD_TEST_EDGE_GATEWAY']

  context "natRouted network" do

    before(:each) do
      @fsi = Vcloud::Fog::ServiceInterface.new


      @name = "orgVdcNetwork-vcloud-tools-tests #{Time.now.strftime('%s')}"

      @config = {
        :name => @name,
        :description => "Integration Test network #{@name}",
        :vdc_name => "#{TEST_VDC}",
        :fence_mode => 'natRouted',
        :edge_gateway => "#{TEST_EDGE_GATEWAY}",
        :gateway => '10.88.11.1',
        :netmask => '255.255.255.0',
        :dns1 => '8.8.8.8',
        :dns2 => '8.8.4.4',
        :ip_ranges => [
            { :start_address => '10.88.11.100',
              :end_address   => '10.88.11.150' },
            { :start_address => '10.88.11.200',
              :end_address   => '10.88.11.250' },
          ],
      }

    end

    it 'should have been provisioned correctly' do
      pending("Not yet implemented in Fog version") unless @fsi.available_in_fog?(:post_create_org_vdc_network)
      @net = Vcloud::Core::OrgVdcNetwork.provision(@config)
      expect(@net.id).to match(/^[0-9a-f-]+$/)
    end

    after(:each) do
      unless ENV['VCLOUD_TOOLS_RSPEC_NO_DELETE_ORG_VDC_NETWORK']
        @fsi.delete_network(@net.id) if @net
      end
    end

  end

  context "isolated network" do

    before(:each) do
      @fsi = Vcloud::Fog::ServiceInterface.new

      @name = "orgVdcNetwork-vcloud-tools-tests #{Time.now.strftime('%s')}"

      @config = {
        :name => @name,
        :description => "Integration Test network #{@name}",
        :vdc_name => "#{TEST_VDC}",
        :fence_mode => 'isolated',
        :gateway => '10.88.10.1',
        :netmask => '255.255.255.0',
        :dns1 => '8.8.8.8',
        :dns2 => '8.8.4.4',
        :ip_ranges => [
            { :start_address => '10.88.10.100',
              :end_address   => '10.88.10.150' },
            { :start_address => '10.88.10.200',
              :end_address   => '10.88.10.250' },
          ],
      }

    end

    it 'should have been provisioned correctly' do
      pending("Not yet implemented in Fog version") unless @fsi.available_in_fog?(:post_create_org_vdc_network)
      @net = Vcloud::Core::OrgVdcNetwork.provision(@config)
      expect(@net.id).to match(/^[0-9a-f-]+$/)
    end

    after(:each) do
      unless ENV['VCLOUD_TOOLS_RSPEC_NO_DELETE_ORG_VDC_NETWORK']
        @fsi.delete_network(@net.id) if @net
      end
    end

  end

end
