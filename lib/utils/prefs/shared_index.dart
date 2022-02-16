import 'dart:convert';
import 'package:my_wealth/model/index_model.dart';
import 'package:my_wealth/storage/local_box.dart';

class IndexSharedPreferences {
  static const _indexKey = "index_list";

  static Future<void> setIndexList(List<IndexModel> indexList) async {
    // stored the user info to box
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // convert the json to string so we can stored it on the local storage
    List<String> _indexList = [];
    for (IndexModel _index in indexList) {
      _indexList.add(jsonEncode(_index.toJson()));
    }
    LocalBox.putStringList(_indexKey, _indexList);
  }

  static List<IndexModel> getIndexList() {
    // check if the key box is null or not?
    if(LocalBox.keyBox == null) {
      LocalBox.init();
    }

    // get the data from local box
    List<String> _indexList = (LocalBox.getStringList(_indexKey) ?? []);

    // check if the list is empty or not?
    if (_indexList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<IndexModel> _ret = [];
      for (String _indexString in _indexList) {
        IndexModel _index = IndexModel.fromJson(jsonDecode(_indexString));
        _ret.add(_index);
      }

      // return the favourites list
      return _ret;
    }
    else {
      // no data
      return [];
    }
  }
}