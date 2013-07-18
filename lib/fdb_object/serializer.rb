# -*- encoding: utf-8 -*-
# Author: peter@centzy.com (Peter Edge)

module FDBObject
  class Serializer

    # identify the type of serialization with a string
    # this will be used as part of the key for the object to identify the serialization type
    def id
      raise NotImplementedError.new
    end

    def serialize(object)
      raise NotImplementedError.new
    end

    def deserialize(object, object_class)
      raise NotImplementedError.new
    end

    # return a name for the object class
    # this is used instead of object_class.name for language-independent serializers
    def object_class_name(object_class)
      raise NotImplementedError.new
    end
  end
end
