import 'dart:typed_data';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:my_wealth/_index.g.dart';

class LocalBox {
  static Box<dynamic>? _keyBox;
  static Box<dynamic>? _encryptedBox;

  static Future<void> init() async {
    if(_keyBox == null) {
      Log.info(message: "📦 Initialize Box");
      _keyBox = await Hive.openBox('storage', compactionStrategy: ((entries, deletedEntries) {
        return deletedEntries > 50;
      }));
    }

    List<int> key = [];
    Uint8List keyInt;
    // check whether we already have key or not?
    if(!_keyBox!.containsKey('key')) {
      // don't have key, so we need to generate a new key
      key = Hive.generateSecureKey();
      keyInt = key as Uint8List;
      _keyBox!.put('key', key);
    }
    else {
      // key already exists, get the current key
      key = _keyBox!.get('key');
      keyInt = key as Uint8List;
    }

    // open the encrypted box based on the key we have
    if (_encryptedBox == null) {
      Log.info(message: "🔐 Initialized Secured Box");
      _encryptedBox = await Hive.openBox('vault', encryptionCipher: HiveAesCipher(keyInt), compactionStrategy: (entries, deletedEntries) {
        return deletedEntries > 10;
      },);
    }
  }

  static Future<void> putString({
    required String key,
    required String value
  }) async {
    // check if keyBox still null?
    if (_keyBox == null) {
      await init();
    }

    // put the key and string value to the keyBox
    _keyBox!.put(key, value);
  }

  static Future<void> putStringList({
    required String key,
    required List<String> value
  }) async {
    // check if keyBox still null?
    if (_keyBox == null) {
      await init();
    }

    // put the key and string value to the keyBox
    _keyBox!.put(key, value);
  }

  static String? getString({required String key}) {
    // if null then return null
    if (_keyBox == null) {
      return null;
    }
    else {
      // check if contains key or not?
      if (_keyBox!.containsKey(key)) {
        return _keyBox!.get(key).toString();
      }
      else {
        return null;
      }
    }
  }

  static List<String>? getStringList({required String key}) {
    // if null then return null
    if (_keyBox == null) {
      return null;
    }
    else {
      // check if contains key for the string list or not?
      if (_keyBox!.containsKey(key)) {
        return List<String>.from(_keyBox!.get(key));
      }
      else {
        return [];
      }
    }
  }

  static Future<void> putSecuredString({
    required String key,
    required String value
  }) async {
    // check if keyBox still null?
    if (_encryptedBox == null) {
      await init();
    }

    // put the key and string value to the keyBox
    _encryptedBox!.put(key, value);
  }

  static String? getSecuredString({
    required String key
  }) {
    // if null then return null
    if (_encryptedBox == null) {
      return null;
    }
    else {
      // check if contains key or not?
      if (_encryptedBox!.containsKey(key)) {
        return _encryptedBox!.get(key).toString();
      }
      else {
        return null;
      }
    }
  }

  static Future<void> clear() async {
    // clear both the key box and encrypted box
    // first clear the box
    if (_keyBox != null) {
      // loop thru all the key box keys
      Iterable<dynamic> keys = _keyBox!.keys;
      for(var key in keys) {
        // check if this is "key", if so don't delete this so we can still
        // open the encrypted box later on
        if(key.toString().toLowerCase() != "key") {
          _keyBox!.delete(key);
        }
      }

      // compact the storage
      await _keyBox!.compact();
    }

    // then clear the encrytped box
    if (_encryptedBox != null) {
      Iterable<dynamic> secureKeys = _encryptedBox!.keys;
      for(var secureKey in secureKeys) {
        _encryptedBox!.delete(secureKey);
      }
    }
  }

  static Future<void> delete({
    required String key,
    bool exact = false,
  }) async {
    // check if key box is not null
    if (_keyBox != null) {
      if (exact) {
        // check if we can find the key on the key box or not?
        if (_keyBox!.containsKey(key)) {
          // delete the ke
          _keyBox!.delete(key);
        }
      }
      else {
        // it's not a case senstive search, so loop thru all the key
        // and see if the key is contain the key string or not?
        Iterable<dynamic> keys = _keyBox!.keys;
        for(var boxKey in keys) {
          // check if the key is on the box key
          String strKey = boxKey.toString();
          if(strKey.contains(key)) {
            // delete this record
            _keyBox!.delete(boxKey);
          }
        }
      }

      // compact the box once finished
      await _keyBox!.compact();
    }
  }
}