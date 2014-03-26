require 'spec_helper'

describe Vcloud::VappDiff do

  context 'with minimum input setup' do

    before(:all) do
      @vdc_name = define_test_data[:vdc_name]
      @non_existant_vapp_name = 'wibble-wobble_jonny_5'
      query_runner = Vcloud::QueryRunner.new
      result = query_runner.run('vApp', {filter: "vdcName==#{@vdc_name};name==#{@non_existant_vapp_name}"})
      fail("VDC contains a vApp called #{@non_existant_vapp_name} - test has been written to use a non existent vApp with this name.") unless result.size == 0
    end

    it 'works as expected' do
      vdc_config_dir = File.join(File.dirname(__FILE__), 'data/vapp_diff_vdc_config')

      missing_vapps = Vcloud::VappDiff.new.run(vdc_config_dir, @vdc_name)

      missing_vapps[:missing_from_env].should == [@non_existant_vapp_name]
      missing_vapps[:missing_from_files].should_not be_nil
    end

  end

  def define_test_data
    {
      vdc_name: ENV['VCLOUD_VDC_NAME'],
    }
  end

end
