# -*- encoding: utf-8 -*-
# Author: peter@centzy.com (Peter Edge)

require 'fdb'

module FDBObject
  class Client

    def initialize(namespace, serializer)
      @namespace = namespace
      @serializer = serializer
      @postfix_provider = PostfixProvider.new(max_postfix_size)
      @db = FDB.open
    end

    def get(key, object_class)
      raise ArgumentError.new unless key && !key.empty?
      raise ArgumentError.new unless object_class

      object_key = object_key(key, object_class)
      values = values(transact { |tr| get_in_transaction(object_key, tr) })
      !values ? nil : deserialize_sub_serialized_objects(object_class, values)
    end

    # TODO(pedge): if keys are close lexographically, can we use ranges?
    def get_many(keys, object_class)
      raise ArgumentError.new unless keys
      keys.each { |key| raise ArgumentError.new unless key && !key.empty? }
      raise ArgumentError.new unless object_class

      key_to_object_key = keys.inject(Hash.new) do |hash, key|
        hash[key] = object_key(key, object_class)
        hash
      end
      key_to_values = transact do |tr|
        key_to_object_key.inject(Hash.new) do |hash, (key, object_key)|
          values = values(get_in_transaction(object_key, tr))
          hash[key] = values if values
          hash
        end
      end
      key_to_values.inject(Hash.new) do |hash, (key, values)|
        hash[key] = deserialized_sub_serialized_objects(object_class, values)
        hash
      end
    end

    def set(key, object)
      raise ArgumentError.new unless key
      raise ArgumentError.new unless object

      object_index_key = object_index_key(key, object.class)
      key_to_sub_serialized_object = key_to_sub_serialized_object(key, object)
      transact do |tr|
        set_in_transaction({object_index_key => key}, tr)
        set_in_transaction(key_to_sub_serialized_object, tr)
      end
      object
    end

    def delete(key, object_class)
      raise ArgumentError.new unless key
      raise ArgumentError.new unless object_class

      object_key = object_key(object_class, key)
      object_index_key = object_index_key(object_class, key)
      transact do |tr|
        delete_in_transaction(object_index_key, tr)
        delete_in_transaction(object_key, tr)
      end
      nil
    end

    def get_all_keys(object_class)
      raise ArgumentError.new unless object_class

      object_index_key = object_index_key(object_class)
      values(transact { |tr| get_in_transaction(object_index_key, tr) })
    end

    attr_reader :namespace, :serializer, :postfix_provider, :db

    MAX_VALUE_SIZE_BYTES = 65536
    MAX_TRANSACTION_SIZE_BYTES = 10 * 1048576

    INDEX_KEY = "index"

    def transact
      db.transact do |tr|
        yield tr
      end
    end

    def get_in_transaction(key, tr)
      tr.get_range(*key.range)
    end

    def set_in_transaction(key_to_value, tr)
      key_to_value.each do |key, value|
        tr.set(key.pack, value)
      end
    end

    def delete_in_transaction(key, tr)
      tr.clear_range(*key.range)
    end

    def values(key_values)
      key_values == nil || key_values.count == 0 ? nil : key_values.map { |key_value| key_value.value }
    end

    def deserialize_sub_serialized_objects(object_class, sub_serialized_objects)
      serialized_object = sub_serialized_objects.inject(StringIO.new.set_encoding(Encoding::BINARY)) do |stringio, sub_serialized_object|
        stringio.write(sub_serialized_object)
        stringio
      end
      serializer.deserialize(serialized_object.string, object_class)
    end

    def key_to_sub_serialized_object(key, object)
      sub_serialized_objects = sub_serialized_objects(object)
      postfixes = PostfixProvider.get(sub_serialized_objects.size)
      index = 0
      sub_serialized_objects.inject(Hash.new) do |hash, sub_serialized_object|
        hash[object_sub_key(key, object.class, postfixes[index])] = sub_serialized_object
        index += 1
        hash
      end
    end

    def sub_serialized_objects(object)
      serialized_object = serializer.serialize(object)
      object_size_bytes = serialized_object.bytesize
      if object_size_bytes > max_object_size_bytes
        raise FDBObjectError.new(OBJECT_TOO_LARGE, "object has byte size of #{object_size_bytes} which is over max byte size of #{max_object_size_bytes}")
      end

      serialized_object_buf = StringIO.new(serialized_object).set_encoding(Encoding::BINARY)
      sub_serialized_objects = Array.new
      sub_serialized_objects << serialized_object_buf.read(MAX_VALUE_SIZE_BYTES) until serialized_object_buf.eof?
      sub_serialized_objects
    end


    def object_key(object_class, key, postfix = nil)
      Key.new(CLIENT_VERSION, namespace, serializer.object_id, serializer.object_class_name(object_class), key, postfix)
    end

    def object_index_key(object_class, key = nil)
      Key.new(CLIENT_VERSION, namespace, serializer.object_id, INDEX_KEY, serializer.object_class_name(object_class), key)
    end

    def max_object_size_bytes
      MAX_TRANSACTION_SIZE_BYTES
    end

    def max_postfix_size
      size_f = MAX_TRANSACTION_SIZE_BYTES.to_f / MAX_VALUE_SIZE_BYTES.to_f
      size_i = size_f.to_i
      size_f == size_i ? size_i : size_i + 1
    end

    class PostfixProvider

      def initialize(max_expected_size)
        @cache = Hash.new
        1.upto(postfix_length_for_size(max_expected_size)) do |postfix_length|
          get_for_postfix_length(postfix_length)
        end
      end

      # note that this may return more postfixes than size
      # slicing an array copies it, this is undesirable
      def get(size)
        get_for_postfix_length(postfix_length_for_size(size))
      end

      private

      attr_reader :cache

      def get_for_postfix_length(postfix_length)
        cache[postfix_length] ||= postfixes_for_length(postfix_length)
        cache[postfix_length]
      end
      
      def postfixes_for_length(postfix_length)
        (('a' * postfix_length)..('z' * postfix_length)).to_a.freeze
      end

      def postfix_length_for_size(size)
        log_f = Math.log(size, 26)
        log_i = log_f.to_i
        log_f == log_i ? log_i : log_i + 1
      end
    end

    class Key

      attr_reader :pack, :range

      def initialize(*parts)
        parts_without_trailing_nils = remove_trailing_nils(parts)
        @pack = pack_parts(parts_without_trailing_nils).freeze
        @range = range_parts(parts_without_trailing_nils).freeze
      end

      private

      def pack_parts(parts)
        FDB::Tuple.pack(parts)
      end

      def range_parts(parts)
        FDB::Tuple.range(parts)
      end

      def remove_trailing_nils(parts)
        dup = parts.dup
        dup.pop until dup.last
        dup
      end
    end
  end
end
