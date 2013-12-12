require 'rubygems'
require 'bundler/setup'
require 'fog'
require 'json'
require 'yaml'
require 'csv'
require 'open3'
require 'pp'

require 'vcloud/version'
require 'vcloud/core'
require 'vcloud/launch'
require 'vcloud/query/query'

module Vcloud

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.clone_object object
    Marshal.load(Marshal.dump(object))
  end

end
