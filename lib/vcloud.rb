require 'rubygems'
require 'bundler/setup'
require 'json'
require 'yaml'
require 'csv'
require 'open3'
require 'pp'

require 'vcloud/version'

require 'vcloud/fog'
require 'vcloud/core'

require 'vcloud/launch'
require 'vcloud/vm_orchestrator'
require 'vcloud/vapp_orchestrator'
require 'vcloud/vapp_diff'
require 'vcloud/missing_vapps_for_vdc'
require 'vcloud/vapp_config'

module Vcloud

  class VdcNotFoundError < RuntimeError; end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.clone_object object
    Marshal.load(Marshal.dump(object))
  end

end
