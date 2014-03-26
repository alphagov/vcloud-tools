require 'spec_helper'

module Vcloud
  describe VappConfig do
    it 'should return a list of vapps contained in the vdcs config files' do
      Dir.stub(:glob){['/path/to/config1', '/path/to/config2']}

      config1 = {:vapps => [{ :name => 'one' }, { :name => 'two' }]}
      config2 = {:vapps => [{ :name => 'jonny-5-is-alive' }]}
      config_loader = double(:config_loader)
      allow(config_loader).to receive(:load_config).and_return(config1, config2,)

      vapp_config = VappConfig.new('path/to/yaml', config_loader)
      result = vapp_config.vapps

      result.should == [{ :name => 'one' }, { :name => 'two' },  { :name => 'jonny-5-is-alive' }]
    end

  end
end

