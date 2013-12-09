require 'spec_helper'

module Vcloud

  describe Vcloud::Vdc do

    before (:each) do
      @mock_fog_interface = StubFogInterface.new
      Vcloud::FogServiceInterface.stub(:new).and_return(@mock_fog_interface)
    end

    context "#initialize" do

      it "should fail if constructed with no args" do
        expect{ Vcloud::Vdc.new() }.to raise_exception(ArgumentError)
      end

      it "should be constructable from just an id reference" do
        obj = Vcloud::Vdc.new('1234578-1234-1234-1234567890ab')
        expect(obj.class).to be(Vcloud::Vdc)
      end

    end

    context "#get_by_name" do

      it "should fail if called with no args" do
        expect { Vcloud::Vdc.get_by_name() }.to raise_exception(ArgumentError)
      end

      it "should return a Vdc object if name exists" do
        obj = Vcloud::Vdc.get_by_name('test-vdc')
        expect(obj.class).to be(Vcloud::Vdc)
      end

    end

  end

end
