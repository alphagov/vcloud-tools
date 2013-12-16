require 'spec_helper'

describe Vcloud::Query do
  context "attributes" do

    context "our object should have methods" do
      before(:each) do
        @mock_fog_interface = StubFogInterface.new
        Vcloud::Fog::ServiceInterface.stub(:new).and_return(@mock_fog_interface)
        @query = Vcloud::Query.new()
      end
      it { @query.should respond_to(:run) }
    end

    context "#run with no type set" do

      before(:each) do
        @mock_fog_interface = StubFogInterface.new
        Vcloud::Fog::ServiceInterface.stub(:new).and_return(@mock_fog_interface)
        @query = @query = Vcloud::Query.new()
      end

      it "should call output_potential_query_types when run not provided with a type" do
        @query.should_receive(:output_potential_query_types)
        @query.run()
      end

      it "should output viable types when run not provided with a type" do
        @mock_fog_interface.stub(:get_execute_query).and_return(
          { :Link => [
            {:rel=>"down",
             :href=>"query?type=alice&#38;format=references"},
            {:rel=>"down",
             :href=>"query?type=alice&#38;format=records"},
            {:rel=>"down",
             :href=>"query?type=bob&#38;format=records"},
        ]})

        @query.should_receive(:puts).with("alice records,references")
        @query.should_receive(:puts).with("bob   records")

        @query.run
      end

    end

    context "gracefully handle zero results" do
      before(:each) do
        @mock_fog_interface = StubFogInterface.new
        Vcloud::Fog::ServiceInterface.stub(:new).and_return(@mock_fog_interface)
        @query = Vcloud::Query.new('bob')
        @mock_fog_interface.stub(:get_execute_query).and_return({})
      end

      it "should not output when given tsv output_format" do
        @query = Vcloud::Query.new('bob', :output_format => 'tsv')
        @query.should_not_receive(:puts)
        @query.run()
      end

      it "should not output when given csv output_format" do
        @query = Vcloud::Query.new('bob', :output_format => 'csv')
        @query.should_not_receive(:puts)
        @query.run()
      end

    end

    context "get results with a single response page" do

      before(:each) do
        @mock_fog_interface = StubFogInterface.new
        Vcloud::Fog::ServiceInterface.stub(:new).and_return(@mock_fog_interface)
        @query = Vcloud::Query.new('bob')
        @mock_fog_interface.stub(:get_execute_query).and_return( {
          :WibbleRecord=>
            [{:field1=>"Stuff 1",
              :field2=>"Stuff 2",
              :field3=>"Stuff 3",
            },
             {:field1=>"More Stuff 1",
              :field2=>"More Stuff 2",
              :field3=>"More Stuff 3",
            },
            ]
        } )
      end

      it "should output a query in tsv when run with a type" do
        @query = Vcloud::Query.new('bob', :output_format => 'tsv')
        @query.should_receive(:puts).with("field1\tfield2\tfield3")
        @query.should_receive(:puts).with("Stuff 1\tStuff 2\tStuff 3")
        @query.should_receive(:puts).with("More Stuff 1\tMore Stuff 2\tMore Stuff 3")
        @query.run()
      end

      it "should output a query in csv when run with a type" do
        @query = Vcloud::Query.new('bob', :output_format => 'csv')
        @query.should_receive(:puts).with("field1,field2,field3\n")
        @query.should_receive(:puts).with("Stuff 1,Stuff 2,Stuff 3\nMore Stuff 1,More Stuff 2,More Stuff 3\n")
        @query.run()
      end

#      it "should output a query in yaml when run with a type"

    end

    context "should handle a single metadata being returned" do

      before(:each) do
        @mock_fog_interface = StubFogInterface.new
        Vcloud::Fog::ServiceInterface.stub(:new).and_return(@mock_fog_interface)
        @query = Vcloud::Query.new('bob')
        @mock_fog_interface.stub(:get_execute_query).and_return( {
          :WibbleRecord=>
            [{:name=>"Thing1",
              :Metadata => {
                :MetadataEntry => {
                  :Key => 'role',
                  :TypedValue => {
                    :xsi_type => 'MetadataStringValue',
                    :Value => 'webserver',
                  },
                },
              },
             },
             {:name=>"Thing2",
              :Metadata => {
                :MetadataEntry => {
                  :Key => 'is_a_thing',
                  :TypedValue => {
                    :xsi_type => 'MetadataBooleanValue',
                    :Value => 'true',
                  },
                },
              },
             },
             {:name=>"Wotsit3",
              :Metadata => {
                :MetadataEntry => {
                  :Key => 'is_a_thing',
                  :TypedValue => {
                    :xsi_type => 'MetadataBooleanValue',
                    :Value => 'false',
                  },
                },
              },
             },
             {:name=>"Numerical4",
              :Metadata => {
                :MetadataEntry => {
                  :Key => 'number_thing',
                  :TypedValue => {
                    :xsi_type => 'MetadataNumberValue',
                    :Value => '53',
                  },
                },
              },
             },
            ]
        } )

      end

      it "should return metadata string values correctly" do
        @query = Vcloud::Query.new('bob',
          :fields => "name,metadata:role,metadata:is_a_thing,metadata:number_thing")
        @query.run().should == [
          {
            :name => "Thing1",
            :"metadata:role" => "webserver",
          },
          {
            :name => "Thing2",
            :"metadata:is_a_thing" => true,
          },
          {
            :name => "Wotsit3",
            :"metadata:is_a_thing" => false,
          },
          {
            :name => "Numerical4",
            :"metadata:number_thing" => 53,
          },
        ]
      end

      it "should output a query in tsv and return metadata correctly" do
        @query = Vcloud::Query.new('bob',
           :fields => "name,metadata:role,metadata:is_a_thing,metadata:number_thing",
           :output_format => 'tsv')
        @query.should_receive(:puts).with("name\tmetadata:role\tmetadata:is_a_thing\tmetadata:number_thing")
        @query.should_receive(:puts).with("Thing1\twebserver\t\t")
        @query.should_receive(:puts).with("Thing2\t\ttrue\t")
        @query.should_receive(:puts).with("Wotsit3\t\tfalse\t")
        @query.should_receive(:puts).with("Numerical4\t\t\t53")
        @query.run()
      end

      it "should output a query in csv and return metadata correctly" do
        @query = Vcloud::Query.new('bob',
           :fields => "name,metadata:role,metadata:is_a_thing,metadata:number_thing",
           :output_format => 'csv')
        @query.should_receive(:puts).with("name,metadata:role,metadata:is_a_thing,metadata:number_thing\n")
        @query.should_receive(:puts).with("Thing1,webserver,,\nThing2,,true,\nWotsit3,,false,\nNumerical4,,,53\n")
        @query.run()
      end

    end

  end

end

