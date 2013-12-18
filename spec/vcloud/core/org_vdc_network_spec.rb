require 'spec_helper'

module Vcloud

  describe Vcloud::Core::OrgVdcNetwork do

    before (:each) do
      @vdc_id    = '12345678-1234-1234-1234-000000111111'
      @edgegw_id = '12345678-1234-1234-1234-000000222222'
      @net_id    = '12345678-1234-1234-1234-000000333333'
      @mock_fog_interface = StubFogInterface.new
      Vcloud::Fog::ServiceInterface.stub(:new).and_return(@mock_fog_interface)
      Vcloud::Core::Vdc.any_instance.stub(:id).and_return(@vdc_id)
    end

    context "Class public interface" do
      it { Vcloud::Core::OrgVdcNetwork.should respond_to(:provision) }
      it { Vcloud::Core::OrgVdcNetwork.should respond_to(:get_by_name) }
    end

    context "Object public interface" do
      subject { Vcloud::Core::OrgVdcNetwork.new(@net_id) }
      it { should respond_to(:delete) }
    end

    context "#initialize" do

      it "should fail if constructed with no args" do
        expect{ Vcloud::Core::OrgVdcNetwork.new() }.to raise_exception(ArgumentError)
      end

      it "should be constructable from just an id reference" do
        obj = Vcloud::Core::OrgVdcNetwork.new('1234578-1234-1234-1234567890ab')
        expect(obj.class).to be(Vcloud::Core::OrgVdcNetwork)
      end

    end

    context "#provision" do

      context "should fail gracefully on bad input" do

        before(:each) do
          @config = {
            :name => 'test-net-1',
            :vdc_name => 'test-vdc-1',
            :fence_mode => 'isolated'
          }
        end

        it "should fail if called with no args" do
          expect { Vcloud::Core::OrgVdcNetwork.provision() }.to raise_exception(ArgumentError)
        end

        it "should fail if :name is not set" do
          @config.delete(:name)
          expect { Vcloud::Core::OrgVdcNetwork.provision(@config) }.to raise_exception(RuntimeError)
        end

        it "should fail if :vdc_name is not set" do
          @config.delete(:vdc_name)
          expect { Vcloud::Core::OrgVdcNetwork.provision(@config) }.to raise_exception(RuntimeError)
        end

        it "should fail if :fence_mode is not set" do
          @config.delete(:fence_mode)
          expect { Vcloud::Core::OrgVdcNetwork.provision(@config) }.to raise_exception(RuntimeError)
        end

        it "should fail if :fence_mode is not 'isolated' or 'natRouted'" do
          @config[:fence_mode] = 'testfail'
          expect { Vcloud::Core::OrgVdcNetwork.provision(@config) }.to raise_exception(RuntimeError)
        end

      end

      context "isolated orgVdcNetwork" do

        before(:each) do
          @config = {
            :name => 'test-net-1',
            :vdc_name => 'test-vdc-1',
            :fence_mode => 'isolated'
          }
        end

        it "should create an OrgVdcNetwork with minimal config" do
          expected_vcloud_attrs = {
            :IsShared => false,
            :Configuration => {
              :FenceMode => 'isolated',
              :IpScopes => {
                :IpScope => {
                  :IsInherited => false,
                  :IsEnabled => true
                }
              }
            },
          }
          @mock_fog_interface.should_receive(:post_create_org_vdc_network).
              with(@vdc_id, @config[:name], expected_vcloud_attrs)
          obj = Vcloud::Core::OrgVdcNetwork.provision(@config)
        end

        it "should handle specification of one ip_ranges" do
          @config[:ip_ranges] = [
            { :start_address => '10.53.53.100', :end_address => '10.53.53.110' }
          ]
          expected_vcloud_attrs = {
            :IsShared => false,
            :Configuration => {
              :FenceMode => 'isolated',
              :IpScopes => {
                :IpScope => {
                  :IsInherited => false,
                  :IsEnabled => true,
                  :IpRanges => [{
                    :IpRange => {:StartAddress => '10.53.53.100', :EndAddress => '10.53.53.110' },
                  }],
                }
              }
            }
          }
          @mock_fog_interface.should_receive(:post_create_org_vdc_network).
              with(@vdc_id, @config[:name], expected_vcloud_attrs)
          obj = Vcloud::Core::OrgVdcNetwork.provision(@config)
          expect(obj.class).to be(Vcloud::Core::OrgVdcNetwork)
        end

        it "should handle specification of two ip_ranges" do
          @config[:ip_ranges] = [
            { :start_address => '10.53.53.100', :end_address => '10.53.53.110' },
            { :start_address => '10.53.53.120', :end_address => '10.53.53.130' },
          ]
          expected_vcloud_attrs = {
            :IsShared => false,
            :Configuration => {
              :FenceMode => 'isolated',
              :IpScopes => {
                :IpScope => {
                  :IsInherited => false,
                  :IsEnabled => true,
                  :IpRanges => [
                    { :IpRange => {:StartAddress => '10.53.53.100', :EndAddress => '10.53.53.110' }},
                    { :IpRange => {:StartAddress => '10.53.53.120', :EndAddress => '10.53.53.130' }},
                  ]
                }
              }
            },
          }
          @mock_fog_interface.should_receive(:post_create_org_vdc_network).
              with(@vdc_id, @config[:name], expected_vcloud_attrs)
          obj = Vcloud::Core::OrgVdcNetwork.provision(@config)
          expect(obj.class).to be(Vcloud::Core::OrgVdcNetwork)
        end

      end

      context "natRouted orgVdcNetwork" do

        before(:each) do
          @config = {
            :name => 'test-net-1',
            :vdc_name => 'test-vdc-1',
            :fence_mode => 'natRouted'
          }
        end

        it "should fail if an edge_gateway is not supplied" do
          expect{ Vcloud::Core::OrgVdcNetwork.provision(@config) }.to raise_exception(RuntimeError)
        end

        it "should handle lack of ip_ranges on natRouted networks" do
          @config[:edge_gateway] = 'test gateway'
          @mock_edgegw = Vcloud::Core::EdgeGateway.new('12345')
          Vcloud::Core::EdgeGateway.stub(:get_by_name).and_return(@mock_edgegw)

          expected_vcloud_attrs = {
            :IsShared => false,
            :Configuration => {
              :FenceMode => 'natRouted',
              :IpScopes => {
                :IpScope => {
                  :IsInherited => false,
                  :IsEnabled => true
                }
              }
            },
            :EdgeGateway => { :href => '/test-edgegw-1' },
          }
          @mock_fog_interface.should_receive(:post_create_org_vdc_network).
              with(@vdc_id, @config[:name], expected_vcloud_attrs)
          obj = Vcloud::Core::OrgVdcNetwork.provision(@config)
        end

      end

    end

  end

end
