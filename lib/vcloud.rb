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

require 'vcloud/config_loader'
require 'vcloud/launch'
require 'vcloud/query'

module Vcloud

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.clone_object object
    Marshal.load(Marshal.dump(object))
  end

  def self.extract_metadata(metadata)
    ret = {}

    metadata = [ metadata ] unless metadata.is_a?(Array)

    metadata.each do |entry|
      # TODO handle pre-5.1 basic Values (TypedValue introduced at 5.1)
      # TODO potentially just consider everything as a string. Lossy, but then 
      #      serialising to YAML later is also lossy :(
      next unless entry.key?(:TypedValue) && entry[:TypedValue].key?(:xsi_type)
      key = entry[:Key].to_sym
      val = entry[:TypedValue][:Value]
      case entry[:TypedValue][:xsi_type]
        when 'MetadataNumberValue'
          val = val.to_i
        when 'MetadataStringValue'
          val = val.to_s
        when 'MetadataDateTimeValue'
          val = DateTime.parse(val)
        when 'MetadataBooleanValue'
          val = val == 'true' ? true : false
      end
      ret[key] = val
    end
    ret
  end

end
