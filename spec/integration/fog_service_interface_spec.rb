require 'spec_helper'

describe Vcloud::FogServiceInterface do
  before(:all) do
    @fog_interface = Vcloud::FogServiceInterface.new
    TEST_CATALOG  = ENV['VCLOUD_TEST_CATALOG']  || 'test-catalog'
  end

  context "catalog" do
    fog_service_interface = Vcloud::FogServiceInterface.new
    it "should retrieve catalog by name" do
      catalog = fog_service_interface.catalog(TEST_CATALOG)
      catalog.should_not be_nil
      catalog[:name].should == TEST_CATALOG
    end

    it "should return nil if catalog with given name not found" do
      catalog = fog_service_interface.catalog('random-name-fake-catalog-which-does-not-exist')
      catalog.should be_nil
    end
  end
end


