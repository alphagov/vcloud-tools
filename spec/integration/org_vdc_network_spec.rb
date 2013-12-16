require 'spec_helper'
require 'pp'

describe Vcloud::Core::OrgVdcNetwork do

  before(:all) do
    @fsi = Vcloud::Fog::ServiceInterface.new

    TEST_VDC      = ENV['VCLOUD_TEST_VDC']      || 'Test vDC'

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
    }

  end

  it 'should have been provisioned correctly' do
    pending("Not yet implemented in Fog version") unless @fsi.available_in_fog?(:post_create_org_vdc_network)
    @net = Vcloud::Core::OrgVdcNetwork.provision(@config)
    expect(@net.id).to match(/^[0-9a-f-]+$/)
  end

  after(:all) do
    unless ENV['VCLOUD_TOOLS_RSPEC_NO_DELETE_ORG_VDC_NETWORK']
      @fsi.delete_network(@net.id) if @net
    end
  end

end
