# -*- encoding: utf-8 -*-
# Author: peter@centzy.com (Peter Edge)

lib = File.expand_path File.dirname(__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'fdb'

require 'msgpack'
require 'multi_json'
require 'yaml'

require 'fdb_object/client'
require 'fdb_object/serializer'
require 'fdb_object/serialization/json_serializer'
require 'fdb_object/serialization/marshal_serializer'
require 'fdb_object/serialization/message_pack_serializer'
require 'fdb_object/serialization/yaml_serializer'
require 'fdb_object/version'

module FDBObject
  
  FDB.api_version(22)

  class FDBObjectError < StandardError
      
    OBJECT_TOO_LARGE = "OBJECT_TOO_LARGE"

    attr_accessor :code

    def initialize(code, message)
      super(message)
      @code = code
    end
  end
end