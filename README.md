fdb_object
==========

FoundationDB Object Layer for Ruby.

This is the beginning of an object layer for FoundationDB. The code is terrible,
there are no tests, and this was just pulled out of a prototype project, but we
have used this for data sets over 100GB already and it has performed well. Our hope
is that the larger FoundationDB community can help develop this into something real.

The main component is FDBObject::Client. This exposes a few methods

* get(db_or_tr, key, object_class): get an object by key and class, return an object or nil
* get_many(db_or_tr, keys, object_class): get objects by key and class, return a map from key to object
* set(db_or_tr, key, object): set a key to an object
* set_many(db_or_tr, key_to_object): set keys to objects
* delete(db_or_tr, key, object_class): delete an object by key
* delete_many(db_or_tr, keys, object class): delete objects by key
* get_all_keys(db_or_key, object_class): get all keys for by class

This is very alpha; we have only used get, set, and get_all_keys.

An FDBObject takes in two parameters, a namespace and an FDBObject::Serializer. A namespace
allows one to split up objects into large buckets, and an FDBObject::Serializer takes care
of object serialization in a preferred format. The methods on FDBObject::Serializer are:

* id(): an id to represent the type of serializer, used as part of the key
* serialize(object): serialize an object to a string
* deserialize(string, object_class): deserialize an object
* object_class_name(object_class): return the name for the object class, for language independence

We have put in a few example serializers for ruby marshalling, JSON, MessagePack, and YAML.

The client splits up serialized objects into values smaller than 100,000 bytes (the limit for FoundationDB),
and stores them as ordered values.

Keys are made up of:

[version, namespace, serializer_id, object_class_name, key, index]

Version is a global setting, represented by FDBObject::CLIENT_VERSION, to allow for easy migrations
between iterations of this gem.

### TODO

* Tests!
* Add indirection between keys and values, potentially using garbage collection, to allow for objects
  greater than 10MB in size
* Arbitrary indexing
* Indexing by geohash
* Change history support
