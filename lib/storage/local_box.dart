import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalBox {
  static Box<dynamic>? keyBox;
  static Box<dynamic>? encryptedBox;

  static Future<void> init() async {
    if(keyBox == null) {
      debugPrint("📦 Initialize Box");
      keyBox = await Hive.openBox('storage');
    }
    else {
      // already have keyBox, compact the keyBox
      debugPrint("🗜️ Compact Box");
      await keyBox!.compact();
    }

    List<int> _key = [];
    Uint8List _keyInt;
    // check whether we already have key or not?
    if(!keyBox!.containsKey('key')) {
      // don't have key, so we need to generate a new key
      _key = Hive.generateSecureKey();
      _keyInt = _key as Uint8List;
      keyBox!.put('key', _key);
    }
    else {
      // key already exists, get the current key
      _key = keyBox!.get('key');
      _keyInt = _key as Uint8List;
    }

    // open the encrypted box based on the key we have
    if (encryptedBox == null) {
      debugPrint("🔐 Initialized Secured Box");
      encryptedBox = await Hive.openBox('vault', encryptionCipher: HiveAesCipher(_keyInt));
    }
    else {
      debugPrint("🗜️ Compact Secured Box");
      await encryptedBox!.compact();
    }
  }

  static Future<void> putString(String key, String value) async {
    // check if keyBox still null?
    if (keyBox == null) {
      await init();
    }

    // put the key and string value to the keyBox
    keyBox!.put(key, value);
  }

  static Future<void> putStringList(String key, List<String> value) async {
    // check if keyBox still null?
    if (keyBox == null) {
      await init();
    }

    // put the key and string value to the keyBox
    keyBox!.put(key, value);
  }

  static String? getString(String key) {
    // if null then return null
    if (keyBox == null) {
      return null;
    }
    else {
      // check if contains key or not?
      if (keyBox!.containsKey(key)) {
        return keyBox!.get(key).toString();
      }
      else {
        return null;
      }
    }
  }

  static List<String>? getStringList(String key) {
    // if null then return null
    if (keyBox == null) {
      return null;
    }
    else {
      // check if contains key for the string list or not?
      if (keyBox!.containsKey(key)) {
        return List<String>.from(keyBox!.get(key));
      }
      else {
        return [];
      }
    }
  }

  static Future<void> putSecuredString(String key, String value) async {
    // check if keyBox still null?
    if (encryptedBox == null) {
      await init();
    }

    // put the key and string value to the keyBox
    encryptedBox!.put(key, value);
  }

  static String? getSecuredString(String key) {
    // if null then return null
    if (encryptedBox == null) {
      return null;
    }
    else {
      // check if contains key or not?
      if (encryptedBox!.containsKey(key)) {
        return encryptedBox!.get(key).toString();
      }
      else {
        return null;
      }
    }
  }

  static Future<void> clear() async {
    // clear both the key box and encrypted box
    // first clear the box
    if (keyBox != null) {
      // loop thru all the key box keys
      Iterable<dynamic> keys = keyBox!.keys;
      for(var key in keys) {
        // check if this is "key", if so don't delete this so we can still
        // open the encrypted box later on
        if(key.toString().toLowerCase() != "key") {
          keyBox!.delete(key);
        }
      }

      // compact the storage
      await keyBox!.compact();
    }

    // then clear the encrytped box
    if (encryptedBox != null) {
      Iterable<dynamic> secureKeys = encryptedBox!.keys;
      for(var secureKey in secureKeys) {
        encryptedBox!.delete(secureKey);
      }
    }
  }

  static Future<void> delete(String key, [bool? exact]) async {
    bool _exact = (exact ?? false);

    // check if key box is not null
    if (keyBox != null) {
      if (_exact) {
        // check if we can find the key on the key box or not?
        if (keyBox!.containsKey(key)) {
          // delete the ke
          keyBox!.delete(key);
        }
      }
      else {
        // it's not a case senstive search, so loop thru all the key
        // and see if the key is contain the key string or not?
        Iterable<dynamic> keys = keyBox!.keys;
        for(var boxKey in keys) {
          // check if the key is on the box key
          String strKey = boxKey.toString();
          if(strKey.contains(key)) {
            // delete this record
            keyBox!.delete(boxKey);
          }
        }
      }

      // compact the box once finished
      await keyBox!.compact();
    }
  }
}