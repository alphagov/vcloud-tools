require 'spec_helper'
require 'pp'

describe Vcloud::Vapp do
  before(:all) do
    @fog_interface = Vcloud::FogServiceInterface.new
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

    @net = Vcloud::OrgVdcNetwork.provision(@config)

  end

  it 'should have been provisioned correctly' do
    expect(@net.id).to match(/^[0-9a-f-]+$/)
  end

  after(:all) do
    #unless ENV['VCLOUD_TOOLS_RSPEC_NO_DELETE_ORG_VDC_NETWORK']
    #  @fog_interface.delete_vapp(@vapp_id).should == true
    #end
  end

end
