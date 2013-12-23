require 'spec_helper'

module Vcloud

  describe Vcloud::Core::EdgeGateway do

    before (:each) do
      @edge_id = '12345678-1234-1234-1234-000000111111'
      @mock_fog_interface = StubFogInterface.new
      Vcloud::Fog::ServiceInterface.stub(:new).and_return(@mock_fog_interface)
    end

    context "Class public interface" do
      it { Vcloud::Core::EdgeGateway.should respond_to(:get_by_name) }
    end

    context "Object public interface" do
      subject { Vcloud::Core::EdgeGateway.new(@edge_id) }
      it { should respond_to(:id) }
      it { should respond_to(:vcloud_attributes) }
      it { should respond_to(:name) }
      it { should respond_to(:href) }
    end

    context "#initialize" do

      it "should fail if constructed with no args" do
        expect{ Vcloud::Core::EdgeGateway.new() }.to raise_exception(ArgumentError)
      end

      it "should be constructable from just an id reference" do
        obj = Vcloud::Core::EdgeGateway.new('1234578-1234-1234-1234567890ab')
        expect(obj.class).to be(Vcloud::Core::EdgeGateway)
      end

    end

    context "#get_by_name" do

      it "should fail if called with no args" do
        expect { Vcloud::Core::EdgeGateway.get_by_name() }.to raise_exception(ArgumentError)
      end

      it "should return an EdgeGateway object if name exists" do
        obj = Vcloud::Core::EdgeGateway.get_by_name('test-edgegw-1')
        expect(obj.class).to be(Vcloud::Core::EdgeGateway)
      end

    end

  end

end
