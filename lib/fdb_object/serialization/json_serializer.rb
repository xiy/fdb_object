# -*- encoding: utf-8 -*-
# Author: peter@centzy.com (Peter Edge)

require 'multi_json'

module FDBObject
  class JsonSerializer < Serializer

    def id
      "ruby_multi_json"
    end

    def serialize(object)
      MultiJson.dump(object)
    end

    def deserialize(object, object_class)
      MultiJson.load(object)
    end

    def object_class_name(object_class)
      object_class.name
    end
  end
end
