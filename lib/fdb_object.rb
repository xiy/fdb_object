# -*- encoding: utf-8 -*-
# Author: peter@centzy.com (Peter Edge)

lib = File.expand_path File.dirname(__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fdb'

require 'multi_json'
require 'yaml'

require 'fdb_object/client'
require 'fdb_object/serializer'
require 'fdb_object/serialization/json_serializer'
require 'fdb_object/serialization/marshal_serializer'
require 'fdb_object/serialization/yaml_serializer'
require 'fdb_object/version'

module FDBObject
  
  def self.db(api_version = 22)
    unless @db
      FDB.api_version(api_version)
      @db = FDB.open
    end
    @db
  end

  class FDBObjectError < StandardError
      
    OBJECT_TOO_LARGE = "OBJECT_TOO_LARGE"

    attr_accessor :code

    def initialize(code, message)
      super(message)
      @code = code
    end
  end
end
