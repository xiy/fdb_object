# -*- encoding: utf-8 -*-
# Author: peter@centzy.com (Peter Edge)

module FDBObject
  class Serializer

    def object_id
      raise NotImplementedError.new
    end

    def serialize(object)
      raise NotImplementedError.new
    end

    def deserialize(object, object_class)
      raise NotImplementedError.new
    end

    def object_class_name(object_class)
      raise NotImplementedError.new
    end
  end
end
