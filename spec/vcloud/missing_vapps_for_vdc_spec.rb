require 'spec_helper'

module Vcloud
  describe MissingVappsForVdc do

    context '#from_config' do

      before(:each) {
        @query_runner = double(Vcloud::QueryRunner)
        allow(@query_runner).to receive(:run).with('orgVdc', anything) { [:a_vdc] }
      }

      it 'should return a list of vapps only present in the environment' do

        allow(@query_runner).to receive(:run).with('vApp', anything) {
          [{:name => 'that'}, {:name => 'this'}]
        }
        vapps_config = double(:vdc_vapps_config, :vapps => [{:name => 'this'}, {:name => 'the other'}])

        missing_vapps = MissingVappsForVdc.new('my vdc', @query_runner, vapps_config)

        missing_vapps.from_config.should == ['that']
      end

      it 'should handle no vapps in env' do
        allow(@query_runner).to receive(:run).with('vApp', anything) { [] }
        vapps_config = double(:vdc_vapps_config, :vapps => [{:name => 'this'}, {:name => 'the other'}])

        missing_vapps = MissingVappsForVdc.new('my vdc', @query_runner, vapps_config)

        missing_vapps.from_config.should be_empty
      end

      it 'should handle no vapps in config' do
        allow(@query_runner).to receive(:run).with('vApp', anything) { [{:name => 'that'}, {:name => 'this'}] }
        vapps_config = double(:vdc_vapps_config, :vapps => [])

        missing_vapps = MissingVappsForVdc.new('my vdc', @query_runner, vapps_config)

        missing_vapps.from_config.should include('that', 'this')
        missing_vapps.from_config.size.should == 2
      end

    end

    context '#from_environment' do

      before(:each) {
        @query_runner = double(Vcloud::QueryRunner)
        allow(@query_runner).to receive(:run).with('orgVdc', anything) { [:a_vdc] }
      }


      it 'should return a list of vapps only present in config' do
        allow(@query_runner).to receive(:run).with('vApp', anything) {
          [{:name => 'that'}, {:name => 'this'}]
        }
        vapps_config = double(:vdc_vapps_config, :vapps => [{:name => 'this'}, {:name => 'the other'}])

        missing_vapps = MissingVappsForVdc.new('my vdc', @query_runner, vapps_config)

        missing_vapps.from_environment.should == ['the other']
      end

      it 'should handle no vapps in env' do
        allow(@query_runner).to receive(:run).with('vApp', anything) { [] }
        vapps_config = double(:vdc_vapps_config, :vapps => [{:name => 'this'}, {:name => 'the other'}])

        missing_vapps = MissingVappsForVdc.new('my vdc', @query_runner, vapps_config)

        missing_vapps.from_environment.should include('this', 'the other')
        missing_vapps.from_environment.size.should == 2
      end

      it 'should handle no vapps in config' do
        allow(@query_runner).to receive(:run).with('vApp', anything) { [{:name => 'that'}, {:name => 'this'}] }
        vapps_config = double(:vdc_vapps_config, :vapps => [])

        missing_vapps = MissingVappsForVdc.new('my vdc', @query_runner, vapps_config)

        missing_vapps.from_environment.should be_empty
      end
    end

    context 'when VDC does NOT exist' do

      before(:each) {
        @query_runner = double(Vcloud::QueryRunner)
        allow(@query_runner).to receive(:run).with('orgVdc', anything) { [] }
      }

      it 'should raise an error when vdc does not exist in environment' do
        vapps_config = double(:vdc_vapps_config, :vapps => [])

        expect {
          MissingVappsForVdc.new('my vdc', @query_runner, vapps_config)
        }.to raise_error(Vcloud::VdcNotFoundError)
      end
    end

  end
end
