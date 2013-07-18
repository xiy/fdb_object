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
