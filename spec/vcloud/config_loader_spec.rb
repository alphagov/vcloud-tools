require 'spec_helper'

module Vcloud
  describe ConfigLoader do

    before(:all) do
      @valid_config = valid_config
    end

    context "#load_config" do

      it "should create a valid hash when input is JSON" do
        input_file = 'spec/vcloud/data/working.json'
        loader = Vcloud::ConfigLoader.new
        actual_config = loader.load_config(input_file)
        valid_config.should eq(actual_config)
      end

      it "should create a valid hash when input is YAML" do
        input_file = 'spec/vcloud/data/working.yaml'
        loader = Vcloud::ConfigLoader.new
        actual_config = loader.load_config(input_file)
        valid_config.should eq(actual_config)
      end

      it "should create a valid hash when input is YAML with anchor defaults" do
        input_file = 'spec/vcloud/data/working_with_defaults.yaml'
        loader = Vcloud::ConfigLoader.new
        actual_config = loader.load_config(input_file)
        valid_config['vapps'].should eq(actual_config['vapps'])
      end

    end

    context "#validate_config" do

      before(:each) do
        @cl = ConfigLoader.new
        @pre = 'ConfigLoader.validate_config'
      end

      it "should raise an error if nil is provided" do
        expect { @cl.validate_config(nil) }.
          to raise_error("#{@pre}: config cannot be nil")
      end

      it "should raise an error if empty hash is provided" do
        expect { @cl.validate_config({}) }.
          to raise_error("#{@pre}: config must not be empty")
      end

      it "should raise an error if input is not a Hash" do
        expect { @cl.validate_config([]) }.
          to raise_error("#{@pre}: config must be a Hash")
      end

      it "should raise an error if an unexpected parameter is provided" do
        expect { @cl.validate_config({ bogus: true }) }.
          to raise_error("#{@pre}: 'bogus' is not a valid configuration parameter")
      end

      it "should pass vapp section to validate_vapp_config" do
        @cl.should_receive(:validate_vapp_config).with('wibble1')
        @cl.should_receive(:validate_vapp_config).with('wibble2')
        @cl.validate_config( { vapps: [ 'wibble1', 'wibble2' ] } )
      end

      it "should not raise an error if no vapps are provided" do
        expect { @cl.validate_app_config({ vapps: [] }) }.
          to be_true
      end

    end

    context "#validate_vapp_config" do
      before(:each) do
        @cl = ConfigLoader.new
        @pre = 'ConfigLoader.validate_vapp_config'
        @basic_config = {
          name:     "test-vapp-1",
          vdc_name: "Test vDC1",
          catalog:  'org-1-catalog',
          catalog_item: 'org-1-template',
        }
        @full_config = {
          name:     "test-vapp-1",
          vdc_name: "Test vDC1",
          catalog:  'org-1-catalog',
          catalog_item: 'org-1-template',
          vm: {
            network_connections: [
              { name: 'org-vdc-1-net-1' }
            ]
          },
        }
      end

      it "should raise an error if nil vapp is provided" do
        expect { @cl.validate_vapp_config(nil) }.
          to raise_error("#{@pre}: config cannot be nil")
      end

      it "should raise an error if input is not a Hash" do
        expect { @cl.validate_vapp_config('bogus') }.
          to raise_error("#{@pre}: config must be a Hash")
      end

      it "should raise an error if empty vapp is provided" do
        expect { @cl.validate_vapp_config({}) }.
          to raise_error("#{@pre}: config must not be empty")
      end

      it "should raise an error if an unexpected parameter is provided" do
        expect { @cl.validate_vapp_config({ bogus: true }) }.
          to raise_error("#{@pre}: 'bogus' is not a valid configuration parameter")
      end

      ['name', 'vdc_name', 'catalog', 'catalog_item'].each do |p|
        it "should raise an error if #{p} is not specified" do
          @basic_config.delete(p.to_sym)
          expect { @cl.validate_vapp_config(@basic_config) }.
            to raise_error("#{@pre}: #{p} is required")
        end
      end

      it "should not raise an error if no vm is specified" do
        expect { @cl.validate_vapp_config(@basic_config) }.
          to be_true
      end

      it "should pass vm section to validate_vm_config" do
        @basic_config[:vm] = {}
        @cl.should_receive(:validate_vm_config).with({})
        @cl.validate_vapp_config( @basic_config )
      end

    end

    context "#validate_vm_config" do
      before(:each) do
        @cl = ConfigLoader.new
        @pre = 'ConfigLoader.validate_vm_config'
        @config = {
          network_connections: [
            { name: 'org-vdc-1-net-1' }
          ]
        }
      end

      it "should raise an error if an empty vm is specified" do
        expect { @cl.validate_vm_config({}) }.
          to raise_error("#{@pre}: config must not be empty")
      end

      it "should raise an error if vm config is not a hash" do
        expect { @cl.validate_vm_config([]) }.
          to raise_error("#{@pre}: config must be a Hash")
      end

      it "should raise an error if an unexpected parameter is provided" do
        expect { @cl.validate_vm_config({ bogus: true }) }.
          to raise_error("#{@pre}: 'bogus' is not a valid configuration parameter")
      end

      it "should raise an error if an empty storage_profile is provided" do
        expect { @cl.validate_vm_config({ storage_profile: "" }) }.
          to raise_error("#{@pre}: storage_profile must not be empty")
      end

      it "should raise an error if a hash storage_profile is provided" do
        expect { @cl.validate_vm_config({ storage_profile: {} }) }.
          to raise_error("#{@pre}: storage_profile must be a String")
      end

      it "should pass metadata section to validate_metadata_config" do
        @cl.should_receive(:validate_metadata_config).with({})
        @cl.validate_vm_config( { metadata: {} } )
      end

      it "should pass hardware_config section to validate_vm_hardware_config" do
        @cl.should_receive(:validate_vm_hardware_config).with({ cpu: '2'})
        @cl.validate_vm_config( { hardware_config: { cpu: '2' } } )
      end

      it "should pass network_connections section to validate_vm_network_connections" do
        @cl.should_receive(:validate_vm_network_connections).with(['1', '2'])
        @cl.validate_vm_config( { network_connections: [ '1', '2' ] } )
      end

      it "should pass bootstrap section to validate_vm_bootstrap_config" do
        @cl.should_receive(:validate_vm_bootstrap_config).with({ script_path: 'wibble'})
        @cl.validate_vm_config( { bootstrap: { script_path: 'wibble' } } )
      end

    end

    context "#validate_metadata_config" do
      before(:each) do
        @cl = ConfigLoader.new
        @pre = 'ConfigLoader.validate_metadata_config'
      end

      it "should raise an error if metadata is not a hash" do
        expect { @cl.validate_metadata_config([]) }.
          to raise_error("#{@pre}: config must be a Hash")
      end

    end

    context "#validate_vm_hardware_config" do
      before(:each) do
        @cl = ConfigLoader.new
        @pre = 'ConfigLoader.validate_vm_hardware_config'
      end

      it "should raise an error if hardware_config is not a hash" do
        expect { @cl.validate_vm_hardware_config([]) }.
          to raise_error("#{@pre}: config must be a Hash")
      end

      it "should raise an error if an unexpected parameter is provided" do
        expect { @cl.validate_vm_hardware_config({ bogus: true }) }.
          to raise_error("#{@pre}: 'bogus' is not a valid configuration parameter")
      end

      it "should raise an error if cpu is not numerical" do
        expect { @cl.validate_vm_hardware_config({ cpu: '4 cpus'}) }.
          to raise_error("#{@pre}: cpu '4 cpus' is not valid" )
      end

      it "should raise an error if memory is not numerical" do
        expect { @cl.validate_vm_hardware_config({ memory: '4096 gigaboggles'}) }.
          to raise_error("#{@pre}: memory '4096 gigaboggles' is not valid" )
      end

    end

    context "#validate_vm_network_connections" do
      before(:each) do
        @cl = ConfigLoader.new
        @pre = 'ConfigLoader.validate_vm_network_connections'
      end

      it "should raise an error if network_connections is not an array" do
        expect { @cl.validate_vm_network_connections({}) }.
          to raise_error("#{@pre}: config must be a Array")
      end

      it "should raise an error if network_connections entry contains an unexpected param" do
        expect { @cl.validate_vm_network_connections([{ bogus: true }]) }.
          to raise_error("#{@pre}: 'bogus' is not a valid configuration parameter")
      end

      it "should raise an error if network_connections entry is not a hash" do
        expect { @cl.validate_vm_network_connections([ 'bogus' ]) }.
          to raise_error("#{@pre}: config must be a Hash" )
      end

      it "should raise an error if network_connections entry does not have a name" do
        expect { @cl.validate_vm_network_connections([{ ip_address: "192.168.1.1" }]) }.
          to raise_error("#{@pre}: name is required" )
      end

      it "should raise an error if network_connections entry :name is empty" do
        expect { @cl.validate_vm_network_connections([{ name: "" }]) }.
          to raise_error("#{@pre}: name must not be empty" )
      end

      it "should raise an error if network_connections entry :name is not a string" do
        expect { @cl.validate_vm_network_connections([{ name: 42 }]) }.
          to raise_error("#{@pre}: name must be a String" )
      end

      it "should not raise an error if network_connections entry :ip_address is not specified" do
        expect { @cl.validate_vm_network_connections([{ name: "valid-net-name" }]) }.
          to be_true
      end

      it "should raise an error if :ip_address entry is not a string" do
        expect { @cl.validate_vm_network_connections([{ name: 'valid-net-name', ip_address: 42 }]) }.
          to raise_error("#{@pre}: ip_address must be a String" )
      end

      it "should raise an error if :ip_address entry is specified, but empty" do
        expect { @cl.validate_vm_network_connections([{ name: 'valid-net-name', ip_address: '' }]) }.
          to raise_error("#{@pre}: ip_address must not be empty")
      end

      it "should raise an error if :ip_address entry is not a correctly formed IP address" do
        expect { @cl.validate_vm_network_connections([{ name: 'valid-net-name', ip_address: '1234.123.123.123' }]) }.
          to raise_error("#{@pre}: ip_address '1234.123.123.123' is not valid" )
      end

    end

    context "#validate_vm_bootstrap_config" do
      before(:each) do
        @cl = ConfigLoader.new
        @pre = 'ConfigLoader.validate_vm_bootstrap_config'
      end

      it "should raise an error if bootstrap is empty" do
        expect { @cl.validate_vm_bootstrap_config({}) }.
          to raise_error("#{@pre}: config must not be empty")
      end

      it "should raise an error if bootstrap contains an unexpected param" do
        expect { @cl.validate_vm_bootstrap_config({ bogus: true }) }.
          to raise_error("#{@pre}: 'bogus' is not a valid configuration parameter")
      end

    end

    def valid_config
      {
        :vapps=>[{
          :name=>"vapp-vcloud-tools-tests",
          :vdc_name=>"VDC_NAME",
          :catalog=>"CATALOG_NAME",
          :catalog_item=>"CATALOG_ITEM",
          :vm=>{
            :hardware_config=>{:memory=>"4096", :cpu=>"2"},
            :extra_disks=>[{:size=>"8192"}],
            :network_connections=>[{
              :name=>"Default",
              :ip_address=>"192.168.2.10"
              },
              {
              :name=>"NetworkTest2",
              :ip_address=>"192.168.1.10"
            }],
            :bootstrap=>{
              :script_path=>"spec/data/basic_preamble_test.erb",
              :vars=>{:message=>"hello world"}
            },
            :metadata=>{}
          }
        }]
      }
    end

  end

end
