# -*- encoding: utf-8 -*-
# Author: peter@centzy.com (Peter Edge)

module FDBObject
  class MarshalSerializer < Serializer

    def id
      "ruby_marshal"
    end

    def serialize(object)
      Marshal.dump(object)
    end

    def deserialize(string, object_class)
      Marshal.load(object)
    end

    def object_class_name(object_class)
      object_class.name
    end
  end
end
