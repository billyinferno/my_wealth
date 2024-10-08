import 'dart:convert';
import 'package:my_wealth/_index.g.dart';

class IndexSharedPreferences {
  static const _indexKey = "index_list";

  static Future<void> setIndexList({
    required List<IndexModel> indexList
  }) async {
    // convert the json to string so we can stored it on the local storage
    List<String> indexListResp = [];
    for (IndexModel index in indexList) {
      indexListResp.add(jsonEncode(index.toJson()));
    }
    LocalBox.putStringList(
      key: _indexKey,
      value: indexListResp
    );
  }

  static List<IndexModel> getIndexList() {
    // get the data from local box
    List<String> indexList = (LocalBox.getStringList(key: _indexKey) ?? []);

    // check if the list is empty or not?
    if (indexList.isNotEmpty) {
      // list is not empty, parse the string to FavouriteModel
      List<IndexModel> ret = [];
      for (String indexString in indexList) {
        IndexModel index = IndexModel.fromJson(jsonDecode(indexString));
        ret.add(index);
      }

      // return the favourites list
      return ret;
    }
    else {
      // no data
      return [];
    }
  }
}