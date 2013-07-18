# -*- encoding: utf-8 -*-
# Author: peter@centzy.com (Peter Edge)

require 'yaml'

module FDBObject
  class YamlSerializer < Serializer

    def id
      "ruby_yaml"
    end

    def serialize(object)
      YAML.dump(object)
    end

    def deserialize(string, object_class)
      YAML.load(object)
    end

    def object_class_name(object_class)
      object_class.name
    end
  end
end
