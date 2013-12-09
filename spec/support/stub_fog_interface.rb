require 'ostruct'

class StubFogInterface

  def name
    'Test vDC 1'
  end

  def vdc_object_by_name(vdc_name)
    vdc = OpenStruct.new
    vdc.name = 'test-vdc-1'
    vdc
  end

  def template
    { :href => '/vappTemplate-12345678-90ab-cdef-0123-4567890abcde' }
  end

  def find_networks(network_names, vdc_name)
    [{
      :name => 'org-vdc-1-net-1',
      :href => '/org-vdc-1-net-1-id',
    }]
  end

  def get_vapp(id)
    { :name => 'test-vapp-1' }
  end

  def get_execute_query(type, options)
    if type == 'orgVdcNetwork' && options[:filter] == 'name==test-net-1'
      return stub_return_single_record(
        :type => type,
        :name => name,
        :href => "/12345678-1234-1234-000005000000",
      )
    else
      return nil
    end
  end

  def vdc(name)
    { :href => '/12345678-90ab-cdef-0123-456789002354' }
  end

  def post_instantiate_vapp_template(vdc, template, name, params)
    {
      :href => '/test-vapp-1-id',
      :Children => {
        :Vm => ['bogus vm data']
      }
    }
  end

  def get_vapp_by_vdc_and_name
    { }
  end

  def template(catalog_name, name)
    { :href => '/vappTemplate-12345678-90ab-cdef-0123-4567890abcde' }
  end

  def post_create_org_vdc_network(vdc_id, name, options)
    return
  end

  private

  def stub_return_single_record(options)
     { :TestRecord=>
       [{:name=>options[:name],
         :href=>options[:href],
       }]
     }
  end

end
