require 'spec_helper'

module Vcloud

  describe Vcloud::Core::Vdc do

    before (:each) do
      @mock_fog_interface = StubFogInterface.new
      Vcloud::Fog::ServiceInterface.stub(:new).and_return(@mock_fog_interface)
    end

    context "#initialize" do

      it "should fail if constructed with no args" do
        expect{ Vcloud::Core::Vdc.new() }.to raise_exception(ArgumentError)
      end

      it "should be constructable from just an id reference" do
        obj = Vcloud::Core::Vdc.new('1234578-1234-1234-1234567890ab')
        expect(obj.class).to be(Vcloud::Core::Vdc)
      end

    end

    context "#get_by_name" do

      it "should fail if called with no args" do
        expect { Vcloud::Core::Vdc.get_by_name() }.to raise_exception(ArgumentError)
      end

      it "should return a Vdc object if name exists" do
        obj = Vcloud::Core::Vdc.get_by_name('test-vdc')
        expect(obj.class).to be(Vcloud::Core::Vdc)
      end

    end

  end

end
