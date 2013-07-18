# -*- encoding: utf-8 -*-
# Author: peter@centzy.com (Peter Edge)

require 'msgpack'

module FDBObject
  class MessagePackSerializer < Serializer

    def id
      "ruby_message_pack"
    end

    def serialize(object)
      MessagePack.pack(object)
    end

    def deserialize(object, object_class)
      MessagePack.unpack(object)
    end

    def object_class_name(object_class)
      object_class.name
    end
  end
end
